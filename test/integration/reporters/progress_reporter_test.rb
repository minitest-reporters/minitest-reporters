require_relative "../../test_helper"
require "minitest/mock"
require "stringio"
require "ruby-progressbar"

module MinitestReportersTest
  class ProgressReporterTest < TestCase
    def test_progress_bar_is_constructed_with_known_total_count
      create_calls = []
      original_create = ProgressBar.method(:create)
      spy = lambda do |**opts|
        create_calls << opts[:total]
        original_create.call(**opts)
      end

      ProgressBar.stub :create, spy do
        reporter = Minitest::Reporters::ProgressReporter.new
        reporter.io = StringIO.new
        reporter.add_defaults(total_count: 7, args: "--seed 1")
        reporter.start
      end

      assert_equal [7], create_calls
    end

    def test_progress_bar_output_goes_to_reporter_io
      io = StringIO.new
      reporter = Minitest::Reporters::ProgressReporter.new
      reporter.io = io
      reporter.add_defaults(total_count: 1, args: "--seed 1")
      reporter.start

      assert_includes io.string, "Progress:"
    end

    def test_all_failures_are_displayed
      fixtures_directory = File.expand_path('../../../fixtures', __FILE__)
      test_filename = File.join(fixtures_directory, 'progress_test.rb')
      output = `#{ruby_executable} #{test_filename} 2>&1`
      assert_match 'test_error', output, 'Errors should be displayed'
      assert_match 'test_failure', output, 'Failures should be displayed'
      assert_match 'test_skip', output, 'Skipped tests should be displayed'
    end
    def test_skipped_tests_are_not_displayed
      fixtures_directory = File.expand_path('../../../fixtures', __FILE__)
      test_filename = File.join(fixtures_directory, 'progress_detailed_skip_test.rb')
      output = `#{ruby_executable} #{test_filename} 2>&1`
      assert_match 'test_error', output, 'Errors should be displayed'
      assert_match 'test_failure', output, 'Failures should be displayed'
      refute_match 'test_skip', output, 'Skipped tests should not be displayed'
    end
    def test_progress_works_with_filter_and_specs
      fixtures_directory = File.expand_path('../../../fixtures', __FILE__)
      test_filename = File.join(fixtures_directory, 'spec_test.rb')
      output = `#{ruby_executable} #{test_filename} -n /length/ 2>&1`
      refute_match '0 out of 0', output, 'Progress should not puts a warning'
    end
    def test_progress_works_with_strict_filter
      fixtures_directory = File.expand_path('../../../fixtures', __FILE__)
      test_filename = File.join(fixtures_directory, 'spec_test.rb')
      output = `#{ruby_executable} #{test_filename} -n /^test_0001_works$/ 2>&1`
      refute_match '0 out of 0', output, 'Progress should not puts a warning'
    end

    private

    def ruby_executable
      defined?(JRUBY_VERSION) ? 'jruby' : 'ruby'
    end
  end
end
