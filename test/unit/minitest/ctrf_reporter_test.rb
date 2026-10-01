# frozen_string_literal: true

require_relative "../../test_helper"
require "json"
require "fileutils"
require "minitest/mock"
require "stringio"
require "tmpdir"

module MinitestReportersTest
  class CTRFReporterUnitTest < Minitest::Test
    def test_writes_mixed_outcomes_in_recording_order_and_counts
      Dir.mktmpdir do |reports_dir|
        with_fixture_class do |fixture_class|
          fixture_class.class_eval do
            define_method(:test_pass) { assert true }
            define_method(:test_multiple_failures) { flunk "first failure" }
            define_method(:test_skip_and_error) { skip "skip before error" }
            define_method(:test_skip_only) { skip "skip only" }
          end

          passing = run_result(fixture_class, "test_pass")
          multiple_failures = run_result(fixture_class, "test_multiple_failures")
          multiple_failures.failures << Minitest::Assertion.new("second failure")

          skip_and_error = run_result(fixture_class, "test_skip_and_error")
          unexpected = RuntimeError.new("unexpected error")
          unexpected.set_backtrace(["unexpected_test.rb:12"])
          skip_and_error.failures << Minitest::UnexpectedError.new(unexpected)

          skipped = run_result(fixture_class, "test_skip_only")
          destination = File.join(reports_dir, "ctrf-report.json")
          artifact = emit_report(
            Minitest::Reporters::CTRFReporter.new(reports_dir),
            destination,
            [passing, multiple_failures, skip_and_error, skipped]
          )

          summary = artifact.fetch("results").fetch("summary")
          assert_equal 4, summary["tests"]
          assert_equal 1, summary["passed"]
          assert_equal 2, summary["failed"]
          assert_equal 1, summary["skipped"]
          assert_equal 0, summary["pending"]
          assert_equal 0, summary["other"]

          rows = artifact.fetch("results").fetch("tests")
          assert_equal(
            ["test_pass", "test_multiple_failures", "test_skip_and_error", "test_skip_only"],
            rows.map { |row| row.fetch("name") }
          )
          assert_equal ["passed", "failed", "failed", "skipped"], rows.map { |row| row.fetch("status") }
          assert_equal "first failure\nsecond failure", rows[1].fetch("message")
          assert_includes rows[2].fetch("message"), "skip before error"
          assert_includes rows[2].fetch("message"), "unexpected error"
        end
      end
    end

    def test_uses_epoch_milliseconds_and_rounds_durations
      Dir.mktmpdir do |reports_dir|
        with_fixture_class do |fixture_class|
          fixture_class.class_eval do
            define_method(:test_timed) { assert true }
          end
          timed = run_result(fixture_class, "test_timed")
          timed.time = 1.2346
          destination = File.join(reports_dir, "ctrf-report.json")
          start_time = Time.at(1_700_000_000, 125_000)
          stop_time = Time.at(1_700_000_002, 375_000)
          clock_values = [start_time, stop_time]

          artifact = nil
          Time.stub(:now, -> { clock_values.shift }) do
            artifact = emit_report(
              Minitest::Reporters::CTRFReporter.new(reports_dir),
              destination,
              [timed]
            )
          end

          summary = artifact.fetch("results").fetch("summary")
          assert_equal 1_700_000_000_125, summary.fetch("start")
          assert_equal 1_700_000_002_375, summary.fetch("stop")
          assert_equal 1_235, artifact.fetch("results").fetch("tests").first.fetch("duration")
        end
      end
    end

    def test_emits_empty_report_without_using_configured_total_count
      Dir.mktmpdir do |reports_dir|
        destination = File.join(reports_dir, "ctrf-report.json")
        artifact = emit_report(
          Minitest::Reporters::CTRFReporter.new(reports_dir, :total_count => 99),
          destination,
          []
        )

        results = artifact.fetch("results")
        assert_equal [], results.fetch("tests")
        summary = results.fetch("summary")
        %w[tests passed failed skipped pending other].each do |field|
          assert_equal 0, summary.fetch(field), field
        end
      end
    end

    def test_preserves_unicode_diagnostics_and_applies_backtrace_filter
      Dir.mktmpdir do |reports_dir|
        with_fixture_class do |fixture_class|
          failure_message = "failure: \"quotes\" — α\nnext line"
          skip_message = "skip: \"quotes\" — β\nnext line"
          fixture_class.class_eval do
            define_method(:test_unicode_failure) { flunk failure_message }
            define_method(:test_unicode_skip) { skip skip_message }
            define_method(:test_nil_backtrace) { flunk "nil backtrace" }
            define_method(:test_unicode_pass) { assert true }
          end

          failure = run_result(fixture_class, "test_unicode_failure")
          failure.name = "test_é_\"quoted\""
          failure.failures.first.set_backtrace(["filtered α", "internal.rb:1", "filtered \"quote\""])

          skipped = run_result(fixture_class, "test_unicode_skip")
          skipped.failures.first.set_backtrace(["filtered α", "internal.rb:2", "filtered \"quote\""])

          nil_backtrace = run_result(fixture_class, "test_nil_backtrace")
          nil_backtrace.failures.first.set_backtrace(nil)

          passing = run_result(fixture_class, "test_unicode_pass")
          destination = File.join(reports_dir, "ctrf-report.json")

          artifact = with_backtrace_filter do
            emit_report(
              Minitest::Reporters::CTRFReporter.new(reports_dir),
              destination,
              [failure, skipped, nil_backtrace, passing]
            )
          end

          rows = artifact.fetch("results").fetch("tests")
          failure_row, skipped_row, nil_backtrace_row, passing_row = rows
          assert_equal "test_é_\"quoted\"", failure_row.fetch("name")
          assert_equal failure_message, failure_row.fetch("message")
          assert_equal skip_message, skipped_row.fetch("message")
          assert_equal "filtered α\nfiltered \"quote\"", failure_row.fetch("trace")
          assert_equal "filtered α\nfiltered \"quote\"", skipped_row.fetch("trace")
          refute nil_backtrace_row.key?("trace")
          refute passing_row.key?("message")
          refute passing_row.key?("trace")
        end
      end
    end

    def test_creates_nested_custom_output_and_honors_environment_directory
      Dir.mktmpdir do |root_dir|
        positional_dir = File.join(root_dir, "positional")
        environment_dir = File.join(root_dir, "from_env", "reports")
        output_filename = File.join("nested", "worker.json")
        destination = File.join(environment_dir, output_filename)

        with_env("MINITEST_REPORTERS_REPORTS_DIR" => environment_dir) do
          reporter = Minitest::Reporters::CTRFReporter.new(
            positional_dir,
            :output_filename => output_filename
          )
          refute File.exist?(environment_dir)
          refute File.exist?(File.dirname(destination))

          artifact = emit_report(reporter, destination, [])

          assert_equal "CTRF", artifact.fetch("reportFormat")
          assert File.file?(destination)
          refute File.exist?(positional_dir)
        end
      end
    end

    def test_replaces_target_without_disturbing_sibling_files
      Dir.mktmpdir do |reports_dir|
        output_filename = File.join("nested", "worker.json")
        destination = File.join(reports_dir, output_filename)
        destination_dir = File.dirname(destination)
        FileUtils.mkdir_p(destination_dir)
        File.write(destination, "old target")
        siblings = {
          "existing.xml" => "xml sibling",
          "existing.json" => "json sibling",
          "sentinel.txt" => "sentinel sibling"
        }
        siblings.each do |filename, contents|
          File.write(File.join(destination_dir, filename), contents)
        end

        artifact = emit_report(
          Minitest::Reporters::CTRFReporter.new(
            reports_dir,
            :output_filename => output_filename
          ),
          destination,
          []
        )

        assert_equal "CTRF", artifact.fetch("reportFormat")
        refute_equal "old target", File.read(destination)
        siblings.each do |filename, contents|
          assert_equal contents, File.read(File.join(destination_dir, filename))
        end
      end
    end

    def test_raises_when_required_parent_is_a_regular_file
      Dir.mktmpdir do |root_dir|
        regular_file = File.join(root_dir, "not_a_directory")
        File.write(regular_file, "not a directory")
        reporter = Minitest::Reporters::CTRFReporter.new(
          root_dir,
          :output_filename => File.join("not_a_directory", "report.json")
        )
        reporter.io = StringIO.new
        reporter.start

        assert_raises(SystemCallError) { reporter.report }
      end
    end

    def test_uses_suite_names_for_results_and_legacy_test_instances
      Dir.mktmpdir do |reports_dir|
        with_fixture_class do |fixture_class|
          fixture_class.class_eval do
            define_method(:test_result) { assert true }
            define_method(:test_legacy) { assert true }
          end

          result = run_result(fixture_class, "test_result")
          legacy_test = fixture_class.new("test_legacy")
          legacy_test.run
          assert_instance_of Minitest::Result, result
          assert_kind_of Minitest::Test, legacy_test

          destination = File.join(reports_dir, "ctrf-report.json")
          artifact = emit_report(
            Minitest::Reporters::CTRFReporter.new(reports_dir),
            destination,
            [result, legacy_test]
          )

          rows = artifact.fetch("results").fetch("tests")
          assert_equal [fixture_class.name], rows[0].fetch("suite")
          assert_equal [fixture_class.name], rows[1].fetch("suite")
          assert_equal ["test_result", "test_legacy"], rows.map { |row| row.fetch("name") }
        end
      end
    end

    private

    def run_result(fixture_class, name)
      fixture_class.new(name).run
    end

    def emit_report(reporter, destination, records)
      reporter.io = StringIO.new
      reporter.start
      records.each { |record| reporter.record(record) }
      reporter.report
      assert File.file?(destination)
      JSON.parse(File.read(destination))
    end

    def with_fixture_class
      original_runnables = Minitest::Runnable.runnables.dup
      fixture_class = Class.new(Minitest::Test)
      constant_name = :CTRFReporterFixture
      MinitestReportersTest.const_set(constant_name, fixture_class)
      yield fixture_class
    ensure
      Minitest::Runnable.runnables.replace(original_runnables)
      if MinitestReportersTest.const_defined?(constant_name, false)
        MinitestReportersTest.send(:remove_const, constant_name)
      end
    end

    def with_env(overrides)
      previous = {}
      overrides.each_key { |key| previous[key] = ENV[key] }
      overrides.each do |key, value|
        if value.nil?
          ENV.delete(key)
        else
          ENV[key] = value
        end
      end
      yield
    ensure
      overrides.each_key do |key|
        if previous[key].nil?
          ENV.delete(key)
        else
          ENV[key] = previous[key]
        end
      end
    end

    def with_backtrace_filter
      original_filter = Minitest.backtrace_filter
      filter = Object.new
      def filter.filter(backtrace)
        backtrace.reject { |line| line.start_with?("internal.rb:") }
      end
      Minitest.backtrace_filter = filter
      yield
    ensure
      Minitest.backtrace_filter = original_filter
    end
  end
end
