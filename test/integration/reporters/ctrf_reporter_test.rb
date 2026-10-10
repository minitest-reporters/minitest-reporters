require_relative "../../test_helper"
require "json"
require "open3"
require "rbconfig"
require "tmpdir"

module MinitestReportersTest
  class CTRFReporterTest < TestCase
    REPORTER_ENVIRONMENT_KEYS = %w[
      MINITEST_REPORTER
      TM_PID
      RM_INFO
      TEAMCITY_VERSION
      VIM
      REPORTER
    ].freeze

    def test_combines_default_and_ctrf_reporters_for_mixed_outcomes
      Dir.mktmpdir do |reports_dir|
        stdout, stderr, status = run_fixture(
          reports_dir,
          "Minitest::Reporters.use!([Minitest::Reporters::DefaultReporter.new, Minitest::Reporters::CTRFReporter.new])"
        )

        refute status.success?
        output = stdout + stderr
        assert_match(/Failure:|Error:/, output)
        assert_includes output, "test_failure"
        assert_includes output, "test_error"

        report = read_report(reports_dir)
        summary = report.fetch("results").fetch("summary")
        assert_equal [4, 1, 2, 1, 0, 0], summary.values_at(
          "tests", "passed", "failed", "skipped", "pending", "other"
        )

        rows = rows_by_name(report)
        assert_equal ["test_error", "test_failure", "test_skip", "test_success"], rows.keys.sort
        assert_equal "passed", rows.fetch("test_success").fetch("status")
        assert_equal "failed", rows.fetch("test_failure").fetch("status")
        assert_equal "failed", rows.fetch("test_error").fetch("status")
        assert_equal "skipped", rows.fetch("test_skip").fetch("status")
      end
    end

    def test_selects_ctrf_reporter_from_environment_and_respects_test_filter
      Dir.mktmpdir do |reports_dir|
        stdout, stderr, status = run_fixture(
          reports_dir,
          "Minitest::Reporters.use!",
          ["-n", "test_success"],
          "CTRFReporter"
        )

        assert status.success?, "#{stdout}\n#{stderr}"

        report = read_report(reports_dir)
        summary = report.fetch("results").fetch("summary")
        assert_equal [1, 1, 0, 0, 0, 0], summary.values_at(
          "tests", "passed", "failed", "skipped", "pending", "other"
        )
        assert_equal ["test_success"], rows_by_name(report).keys
      end
    end

    def test_selects_ctrf_reporter_and_writes_empty_report_for_non_matching_filter
      Dir.mktmpdir do |reports_dir|
        stdout, stderr, status = run_fixture(
          reports_dir,
          "Minitest::Reporters.use!(Minitest::Reporters::CTRFReporter.new)",
          ["-n", "/does_not_exist/"]
        )

        assert status.success?, "#{stdout}\n#{stderr}"

        report = read_report(reports_dir)
        summary = report.fetch("results").fetch("summary")
        assert_equal [0, 0, 0, 0, 0, 0], summary.values_at(
          "tests", "passed", "failed", "skipped", "pending", "other"
        )
        assert_equal [], report.fetch("results").fetch("tests")
      end
    end

    private

    def run_fixture(reports_dir, reporter_setup, arguments = [], selected_reporter = nil)
      environment = ENV.to_hash
      REPORTER_ENVIRONMENT_KEYS.each { |key| environment[key] = nil }
      environment["MINITEST_REPORTERS_REPORTS_DIR"] = reports_dir
      environment["MINITEST_REPORTER"] = selected_reporter if selected_reporter

      program = <<-RUBY
        require "minitest/autorun"
        require "minitest/reporters"
        #{reporter_setup}
        load ARGV.shift
      RUBY
      command = [
        RbConfig.ruby,
        "-I#{repository_lib}",
        "-e",
        program,
        fixture_path
      ] + arguments

      Open3.capture3(environment, *command)
    end

    def read_report(reports_dir)
      report_path = File.join(reports_dir, Minitest::Reporters::CTRFReporter::DEFAULT_OUTPUT_FILENAME)
      JSON.parse(File.read(report_path))
    end

    def rows_by_name(report)
      report.fetch("results").fetch("tests").each_with_object({}) do |row, rows|
        rows[row.fetch("name")] = row
      end
    end

    def repository_lib
      File.expand_path("../../../lib", __dir__)
    end

    def fixture_path
      File.expand_path("../../fixtures/sample_test.rb", __dir__)
    end
  end
end
