require_relative "../../test_helper"

module MinitestReportersTest
  class MeanTimeReporterUnitTest < Minitest::Test
    def setup
      configure_report_paths
      previous_test_run
    end

    def teardown
      File.delete(@previous_run_path) if File.exist?(@previous_run_path)
      File.delete(@report_file_path) if File.exist?(@report_file_path)
    end

    def test_sorts_avg_numerically
      report_output = generate_report(:avg)

      expected_order = [
        'AVG_SLOW',
        'MAX_SLOW',
        'MIN_SLOW',
        'MIDDLE',
        'MIN_FAST',
        'MAX_FAST',
        'AVG_FAST'
      ]
      verify_result_order(report_output, expected_order)
    end

    def test_sorts_min_numerically
      report_output = generate_report(:min)

      expected_order = [
        'MIN_SLOW',
        'AVG_SLOW',
        'MAX_SLOW',
        'MIDDLE',
        'MAX_FAST',
        'AVG_FAST',
        'MIN_FAST'
      ]
      verify_result_order(report_output, expected_order)
    end

    def test_sorts_max_numerically
      report_output = generate_report(:max)

      expected_order = [
        'MAX_SLOW',
        'AVG_SLOW',
        'MIN_SLOW',
        'MIDDLE',
        'MIN_FAST',
        'AVG_FAST',
        'MAX_FAST'
      ]
      verify_result_order(report_output, expected_order)
    end

    def test_sorts_last_numerically
      report_output = generate_report(:last)

      expected_order = [
        'AVG_SLOW',
        'MIN_SLOW',
        'MAX_SLOW',
        'MIDDLE',
        'MIN_FAST',
        'MAX_FAST',
        'AVG_FAST'
      ]
      verify_result_order(report_output, expected_order)
    end

    private

    def simulate_suite_runtime(suite_name, run_time)
      test_suite = Minitest::Test.new(suite_name)
      base_clock_time = Minitest::Reporters.clock_time
      Minitest::Reporters.stub(:clock_time, base_clock_time - run_time) do
        @reporter.before_suite(test_suite)
      end
      @reporter.after_suite(test_suite)
    end

    def previous_test_run
      @reporter = Minitest::Reporters::MeanTimeReporter.new(
        previous_runs_filename: @previous_run_path,
        report_filename: @report_file_path
      )

      simulate_suite_runtime('MIDDLE', 5.0)
      simulate_suite_runtime('MIN_FAST', 0.5)
      simulate_suite_runtime('MIN_SLOW', 10.5)
      simulate_suite_runtime('MAX_FAST', 1.2)
      simulate_suite_runtime('MAX_SLOW', 16.3)
      simulate_suite_runtime('AVG_FAST', 1.3)
      simulate_suite_runtime('AVG_SLOW', 10.2)
      @reporter.tests << Minitest::Test.new('Final')
      # Generate a "previous" run
      @reporter.io = StringIO.new
      @reporter.start
      @reporter.report
    end

    def configure_report_paths
      previous_runs_file = Tempfile.new('minitest-mean-time-previous-runs')
      previous_runs_file.close
      @previous_run_path = previous_runs_file.path
      previous_runs_file.delete
      report_file = Tempfile.new('minitest-mean-time-report')
      report_file.close
      @report_file_path = report_file.path
      report_file.delete
    end

    def generate_report(sort_column)
      # Reset the reporter for the test run
      @reporter = Minitest::Reporters::MeanTimeReporter.new(
        previous_runs_filename: @previous_run_path,
        report_filename: @report_file_path,
        sort_column: sort_column
      )
      simulate_suite_runtime('MIDDLE', 5.0)
      simulate_suite_runtime('MIN_FAST', 3.5)
      simulate_suite_runtime('MIN_SLOW', 10.5)
      simulate_suite_runtime('MAX_FAST', 0.9)
      simulate_suite_runtime('MAX_SLOW', 6.3)
      simulate_suite_runtime('AVG_FAST', 0.65)
      simulate_suite_runtime('AVG_SLOW', 14.2)
      @reporter.tests << Minitest::Test.new('Final')

      report_output = StringIO.new
      @reporter.io = report_output
      @reporter.start
      @reporter.report
      report_output
    end

    def verify_result_order(report_output, expected_order)
      report_output.rewind
      test_lines = report_output.read.split("\n")
      test_lines.select! { |line| line.start_with?('Avg:') }

      # Exclude the final placeholder 0 second test from assertions
      test_lines.reject! { |line| line.end_with?('Minitest::Test') }
      actual_order = test_lines.map { |line| line.gsub(/.*Description: /, '') }

      assert_equal(expected_order, actual_order, "\n#{test_lines.join("\n")}")
    end
  end
end
