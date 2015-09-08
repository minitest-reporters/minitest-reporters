require 'yaml'

module Minitest
  module Reporters

    class MeanTimeReporter < DefaultReporter

      # @param options [Hash]
      # @option previous_runs_filename [String] Contains the times for each test
      #   by description. Defaults to '/tmp/minitest_reporters_previous_run'.
      # @option report_filename [String] Contains the parsed results for the
      #   last test run. Defaults to '/tmp/minitest_reporters_report'.
      # @return [Minitest::Reporters::MeanTimeReporter]
      def initialize(options = {})
        super

        @all_suite_times = []
      end

      # Copies the suite times from the
      # {Minitest::Reporters::DefaultReporter#after_suite} method, making them
      # available to this class.
      #
      # @return [Hash<String => Float>]
      def after_suite(suite)
        super

        @all_suite_times = @suite_times
      end

      # Runs the {Minitest::Reporters::DefaultReporter#report} method and then
      # enhances it by storing the results to the 'previous_runs_filename' and
      # outputs the parsed results to both the 'report_filename' and the
      # terminal.
      #
      def report
        super

        create_or_update_previous_runs!

        create_new_report!
      end

      protected

      attr_accessor :all_suite_times

      private

      # @return [Hash<String => Float>]
      def current_run
        Hash[all_suite_times]
      end

      # @return [Hash] Sets default values for the filenames used by this class.
      def defaults
        {
          previous_runs_filename: '/tmp/minitest_reporters_previous_run',
          report_filename:        '/tmp/minitest_reporters_report',
        }
      end

      # Added to the top of the report file to be helpful.
      #
      # @return [String]
      def report_header
        "Samples: #{samples}\n\n"
      end

      # The report itself. Displays statistic about all runs, ideal for use with
      # the Unix 'head' command. Listed in slowest average descending order.
      #
      # @return [String]
      def report_body
        previous_run.each_with_object([]) do |(description, timings), obj|
          size = timings.size
          sum  = timings.inject { |total, x| total + x }
          avg  = (sum / size).round(9).to_s.ljust(12)
          min  = timings.min.to_s.ljust(12)
          max  = timings.max.to_s.ljust(12)

          obj << "#{avg_label} #{avg} " \
                 "#{min_label} #{min} " \
                 "#{max_label} #{max} " \
                 "#{des_label} #{description}\n"
        end.sort.reverse.join
      end

      # @return [Hash]
      def options
        defaults.merge!(@options)
      end

      # @return [Hash<String => Array<Float>]
      def previous_run
        @previous_run ||= YAML.load_file(previous_runs_filename)
      end

      # @return [String] The path to the file which contains all the durations
      #   for each test run. The previous runs file is in YAML format, using the
      #   test name for the key and an array containing the time taken to run
      #   this test for values.
      #
      # @return [String]
      def previous_runs_filename
        options[:previous_runs_filename]
      end

      # Returns a boolean indicating whether a previous runs file exists.
      #
      # @return [Boolean]
      def previously_ran?
        File.exist?(previous_runs_filename)
      end

      # @return [String] The path to the file which contains the parsed test
      #   results. The results file contains a line for each test with the
      #   average time of the test, the minimum time the test took to run,
      #   the maximum time the test took to run and a description of the test
      #   (which is the test name as emitted by Minitest).
      def report_filename
        options[:report_filename]
      end

      # A barbaric way to find out how many runs are in the previous runs file;
      # this method takes the first test listed, and counts its samples
      # trusting (naively) all runs to be the same number of samples. This will
      # produce incorrect averages when new tests are added, so it is advised
      # to restart the statistics by removing the 'previous runs' file.
      #
      # @return [Fixnum]
      def samples
        return 1 unless previous_run.first[1].is_a?(Array)

        previous_run.first[1].size
      end

      # Creates a new 'previous runs' file, or updates the existing one with
      # the latest timings.
      #
      # @return [void]
      def create_or_update_previous_runs!
        if previously_ran?
          current_run.each do |description, elapsed|
          new_times = if previous_run["#{description}"]
                        Array(previous_run["#{description}"]) << elapsed

                      else
                        Array(elapsed)

                      end

            previous_run.store("#{description}", new_times)
          end

          File.write(previous_runs_filename, previous_run.to_yaml)

        else

          File.write(previous_runs_filename, current_run.to_yaml)

        end
      end

      # Creates a new report file in the 'report_filename'. This file contains
      # a line for each test of the following example format:
      #
      # Avg: 0.0555555 Min: 0.0498765 Max: 0.0612345 Description: The test name
      #
      # Note however the timings are to 9 decimal places, and padded to 12
      # characters and each label is coloured, Avg (yellow), Min (green),
      # Max (red) and Description (blue). It looks pretty!
      #
      # @return [void]
      def create_new_report!
        File.write(report_filename, report_header + report_body)
      end

      # @return [String] A yellow 'Avg:' label.
      def avg_label
        "\e[33mAvg:\e[39m"
      end

      # @return [String] A blue 'Description:' label.
      def des_label
        "\e[34mDescription:\e[39m"
      end

      # @return [String] A red 'Max:' label.
      def max_label
        "\e[31mMax:\e[39m"
      end

      # @return [String] A green 'Min:' label.
      def min_label
        "\e[32mMin:\e[39m"
      end

    end
  end
end
