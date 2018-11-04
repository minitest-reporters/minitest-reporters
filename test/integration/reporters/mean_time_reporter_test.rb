require_relative "../../test_helper"

require 'fileutils'

module MinitestReportersTest
  class MeanTimeReporterTest < TestCase
    # Uncomment this to verify breakage in minitest-reporters 1.3.5 as released
    # def test_reset_statistics_breaks_future_runs
    #   fixtures_directory = File.expand_path('../../../fixtures', __FILE__)
    #   test_filename = File.join(fixtures_directory, 'mean_time_test.rb')
    #   prev_runs_file = Dir.tmpdir + '/minitest_reporters_previous_run'
    #   FileUtils.rm_f(prev_runs_file) # Erase any previous-runs data file
    #   # ----
    #   output1 = `#{ruby_executable} #{test_filename} 2>&1`
    #   assert_equal(output1.lines[0], "\n") # start of successful-run report
    #   # ----
    #   Minitest::Reporters::MeanTimeReporter.reset_statistics!
    #   assert_equal(true, File.empty?(prev_runs_file)) # exists and is empty
    #   # ----
    #   output2 = `#{ruby_executable} #{test_filename} 2>&1`
    #   expected = "`block in create_or_update_previous_runs!': " \
    #     "undefined method `[]' for false:FalseClass (NoMethodError)"
    #   assert_match expected, output2, 'Did not get expected exception message'
    #   FileUtils.rm_f(prev_runs_file) # Remove broken previous-runs data file
    # end

    def test_reset_statistics_does_not_break_future_runs
      fixtures_directory = File.expand_path('../../../fixtures', __FILE__)
      test_filename = File.join(fixtures_directory, 'mean_time_test.rb')
      prev_runs_file = Dir.tmpdir + '/minitest_reporters_previous_run'
      FileUtils.rm_f(prev_runs_file) # Erase any previous-runs data file
      # ----
      output1 = `#{ruby_executable} #{test_filename} 2>&1`
      assert_equal(output1.lines[0], "\n") # start of successful-run report
      # ----
      Minitest::Reporters::MeanTimeReporter.reset_statistics!
      assert_equal(false, File.exist?(prev_runs_file))
      # ----
      output2 = `#{ruby_executable} #{test_filename} 2>&1`
      error_message = "`block in create_or_update_previous_runs!': " \
        "undefined method `[]' for false:FalseClass (NoMethodError)"
      refute_match error_message, output2, 'Got unexpected exception message'
      FileUtils.rm_f(prev_runs_file) # Erase any previous-runs data file on fail
    end

    def test_all_failures_are_displayed
      fixtures_directory = File.expand_path('../../../fixtures', __FILE__)
      test_filename = File.join(fixtures_directory, 'mean_time_test.rb')
      # ----
      output = `#{ruby_executable} #{test_filename} 2>&1`
      # ----
      assert_match "Error:\nLastTestClass#test_error:", output,
        'Errors should be displayed'
      assert_match "Failure:\nTestClass#test_fail ", output,
        'Failures should be displayed'
      assert_match "Skipped:\nAnotherTestClass#test_skip ", output,
        'Skipped tests should be displayed'
    end

    def test_skipped_tests_are_not_displayed
      fixtures_directory = File.expand_path('../../../fixtures', __FILE__)
      test_filename = File.join(fixtures_directory, 'mean_time_detailed_skip_test.rb')
      # ----
      output = `#{ruby_executable} #{test_filename} 2>&1`
      # ----
      assert_match "Error:\nLastTestClass#test_error:", output,
        'Errors should be displayed'
      assert_match "Failure:\nTestClass#test_fail ", output,
        'Failures should be displayed'
      refute_match "Skipped:\nAnotherTestClass#test_skip ", output,
        'Skipped tests should not be displayed'
    end

    def test_show_count_limits_count
      fixtures_directory = File.expand_path('../../../fixtures', __FILE__)
      test_filename = File.join(fixtures_directory, 'mean_time_test.rb')
      base_output = `#{ruby_executable} #{test_filename} 2>&1`
      base_count = base_output.lines.select { |s| s.match(/^Avg: /) }.count
      # ----
      test_filename = File.join(fixtures_directory, 'mean_time_show_count_test.rb')
      output = `#{ruby_executable} #{test_filename} 2>&1`
      count = output.lines.select { |s| s.match(/^Avg: /) }.count
      refute_equal count, base_count, 'show_count had no effect'
    end

    def test_progress_is_not_displayed
      fixtures_directory = File.expand_path('../../../fixtures', __FILE__)
      test_filename = File.join(fixtures_directory, 'mean_time_hide_progress_test.rb')
      # ----
      output = `#{ruby_executable} #{test_filename} 2>&1`
      # ----
      refute_match 'Error:', output, 'Errors should not be displayed'
      refute_match 'Failure:', output, 'Failures should not be displayed'
      refute_match 'Skipped:', output, 'Skipped tests should not be displayed'
    end

    # As a reminder, when set to false, this omits the total time spent running
    # all test, which in this case will have as a "Description" the class name
    # of this test suite, `MinitestReportersTest::MeanTimeReporterTest`.
    def test_dont_show_all_runs
      fixtures_directory = File.expand_path('../../../fixtures', __FILE__)
      test_filename = File.join(fixtures_directory, 'mean_time_hide_all_runs_test.rb')
      # ----
      output = `#{ruby_executable} #{test_filename} 2>&1`
      # ----
      refute_match "Description: #{self.class.name}", output,
        'Total for all runs should not be displayed'
    end

    def test_sort_by_max_time
      fixtures_directory = File.expand_path('../../../fixtures', __FILE__)
      test_filename = File.join(fixtures_directory, 'mean_time_sort_by_max_test.rb')
      # ----
      output = `#{ruby_executable} #{test_filename} 2>&1`
      # ----
      assert_match 'Order: :max :desc', output, 'Output not sorted by max timing'
    end

    def test_sort_in_ascending_order
      fixtures_directory = File.expand_path('../../../fixtures', __FILE__)
      test_filename = File.join(fixtures_directory, 'mean_time_sort_ascending_test.rb')
      # ----
      output = `#{ruby_executable} #{test_filename} 2>&1`
      # ----
      assert_match 'Order: :avg :asc', output, 'Output not sorted in ascending order'
    end

    private

    def ruby_executable
      defined?(JRUBY_VERSION) ? 'jruby' : 'ruby'
    end
  end
end
