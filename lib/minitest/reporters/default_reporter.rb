require 'ansi/code'

module MiniTest
  module Reporters
    # A reporter identical to the standard MiniTest reporter except with more
    # colors.
    #
    # Based upon Ryan Davis of Seattle.rb's MiniTest (MIT License).
    #
    # @see https://github.com/seattlerb/minitest MiniTest
    class DefaultReporter < BaseReporter
      include RelativePosition

      def initialize(options = {})
        super
        @detailed_skip = options.fetch(:detailed_skip, true)
        @slow_count = options.fetch(:slow_count, 0)
        @slow_suite_count = options.fetch(:slow_suite_count, 0)
        @fast_fail = options.fetch(:fast_fail, false)
        @options = options
      end

      def start
        super
        puts
        puts "# Running tests:"
        puts
      end

      def record(test)
        super
        if @fast_fail
          puts
          puts test.name
          print pad_test(test.suite)
          print(red(pad_mark('FAIL')))
          puts
          print_info(test.failure, false)
        else
          result = if test.passed?
            green('.')
          elsif test.skipped?
            yellow('S')
          elsif test.error? || test.failure
            red('F')
          end

          if @options[:verbose]
            puts "#{test.class} #{"%.2f" % test.time} = #{result}"
          else
            print result
          end
        end
      end

      def report
        super
        status_line = "Finished testss in %.6fs, %.4f tests/s, %.4f assertions/s." %
          [total_time, count / total_time, assertions / total_time]

        puts
        puts
        puts colored_for(suite_result, status_line)

        unless @fast_fail
          tests.each do |test|
            if message = message_for(test)
              puts
              print colored_for(result(test), message)
            end
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

      # TODO #when :failure then "Failure:\n#{test}(#{suite}) [#{location(e)}]:\n#{e.message}\n"
      def message_for(test)
        suite = test.class
        e = test.failure

        if test.passed?
          nil
        elsif test.skipped?
          if @detailed_skip
            "Skipped:\n#{test.name}(#{suite}) [#{location(e)}]:\n#{e.message}\n"
          end
        elsif test.error?
          bt = filter_backtrace(e.backtrace).join "\n    "
          "Error:\n#{test.name}(#{suite}):\n#{e.class}: #{e.message}\n    #{bt}\n"
        else
          "Failure:\n#{test.name}(#{suite}):\n#{e.class}: #{e.message}"
        end
      end

      def result_line
        '%d tests, %d assertions, %d failures, %d errors, %d skips' %
          [count, assertions, failures, errors, skips]
      end
    end
  end
end
