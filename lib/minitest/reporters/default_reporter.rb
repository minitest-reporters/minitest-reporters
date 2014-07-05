require 'ansi/code'

module Minitest
  module Reporters
    # A reporter identical to the standard Minitest reporter except with more
    # colors.
    #
    # Based upon Ryan Davis of Seattle.rb's Minitest (MIT License).
    #
    # @see https://github.com/seattlerb/minitest Minitest
    class DefaultReporter < BaseReporter
      include RelativePosition

      def initialize(options = {})
        super
        @detailed_skip = options.fetch(:detailed_skip, true)
        @slow_count = options.fetch(:slow_count, 0)
        @slow_suite_count = options.fetch(:slow_suite_count, 0)
        @suite_times = []
        @suite_start_times = {}
        @fast_fail = options.fetch(:fast_fail, false)
        @options = options
      end

      def start
        super
        puts
        puts "# Running tests:"
        puts
      end

      def before_test(test)
        super
        print "\n#{test.class}##{test.name} " if options[:verbose]
      end

      def before_suite(suite)
        @suite_start_times[suite] = Time.now
        super
      end

      def after_suite(suite)
        super
        @suite_times << [suite.name, Time.now - @suite_start_times.delete(suite)]
      end

      def record(test)
        super

        print "#{"%.2f" % test.time} = " if options[:verbose]

        print(if test.passed?
          record_pass(test)
        elsif test.skipped?
          record_skip(test)
        elsif test.failure
          record_failure(test)
        end)

        if @fast_fail && (test.skipped? || test.failure)
          puts
          print_failure(test)
        end
      end

      def record_pass(test)
        green('.')
      end

      def record_skip(test)
        yellow('S')
      end

      def record_failure(test)
        red('F')
      end

      def report
        super
        status_line = "Finished tests in %.6fs, %.4f tests/s, %.4f assertions/s." %
          [total_time, count / total_time, assertions / total_time]

        puts
        puts
        puts colored_for(suite_result, status_line)

        unless @fast_fail
          tests.reject(&:passed?).each do |test|
            puts
            print_failure(test)
          end
        end

        if @slow_count > 0
          slow_tests = tests.sort_by(&:time).reverse.take(@slow_count)

          puts
          puts "Slowest tests:"
          puts

          slow_tests.each do |test|
            puts "%.6fs %s" % [test.time, "#{test.name}##{test.class}"]
          end
        end

        if @slow_suite_count > 0
          slow_suites = @suite_times.sort_by { |x| x[1] }.reverse.take(@slow_suite_count)

          puts
          puts "Slowest test classes:"
          puts

          slow_suites.each do |slow_suite|
            puts "%.6fs %s" % [slow_suite[1], slow_suite[0]]
          end
        end

        puts
        print colored_for(suite_result, result_line)
        puts
      end

      def print_failure(test)
        puts colored_for(result(test), message_for(test))
      end

      private

      def color?
        return @color if defined?(@color)
        @color = @options.fetch(:color) do
          io.tty? && (
            ENV["TERM"] =~ /^screen|color/ ||
            ENV["EMACS"] == "t"
          )
        end
      end

      def green(string)
        color? ? ANSI::Code.green(string) : string
      end

      def yellow(string)
        color? ? ANSI::Code.yellow(string) : string
      end

      def red(string)
        color? ? ANSI::Code.red(string) : string
      end

      def colored_for(result, string)
        case result
        when :fail, :error; red(string)
        when :skip; yellow(string)
        else green(string)
        end
      end

      def suite_result
        case
        when failures > 0; :fail
        when errors > 0; :error
        when skips > 0; :skip
        else :pass
        end
      end

      def location(exception)
        last_before_assertion = ''

        exception.backtrace.reverse_each do |s|
          break if s =~ /in .(assert|refute|flunk|pass|fail|raise|must|wont)/
          last_before_assertion = s
        end

        last_before_assertion.sub(/:in .*$/, '')
      end

      def message_for(test)
        e = test.failure

        if test.skipped?
          if @detailed_skip
            "Skipped:\n#{test.class}##{test.name} [#{location(e)}]:\n#{e.message}"
          end
        elsif test.error?
          "Error:\n#{test.class}##{test.name}:\n#{e.message}"
        else
          "Failure:\n#{test.class}##{test.name} [#{test.failure.location}]\n#{e.class}: #{e.message}"
        end
      end

      def result_line
        '%d tests, %d assertions, %d failures, %d errors, %d skips' %
          [count, assertions, failures, errors, skips]
      end
    end
  end
end
