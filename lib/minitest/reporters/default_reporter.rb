require 'ansi/code'

module MiniTest
  module Reporters
    # A reporter identical to the standard MiniTest reporter.
    #
    # Based upon Ryan Davis of Seattle.rb's MiniTest (MIT License).
    #
    # @see https://github.com/seattlerb/minitest MiniTest
    class DefaultReporter
      include Reporter

      def initialize(options = {})
        if options.is_a?(Hash)
          @backtrace_filter = options.fetch(:backtrace_filter, BacktraceFilter.default_filter)
          @detailed_skip = options.fetch(:detailed_skip, true)
          @color = options.fetch(:color) do
            output.tty? && (
              ENV["TERM"] == "screen" ||
              ENV["TERM"] =~ /term(?:-(?:256)?color)?\z/ ||
              ENV["EMACS"] == "t"
            )
          end
        else
          warn "Please use :backtrace_filter => filter instead of passing in the filter directly."
          @backtrace_filter = options
          @detailed_skip = true
          @color = false
        end
      end

      def before_suites(suites, type)
        puts
        puts "# Running #{type}s:"
        puts
      end

      def before_test(suite, test)
        print "#{suite}##{test} = " if verbose?
      end

      def pass(suite, test, test_runner)
        after_test(green { '.' })
      end

      def skip(suite, test, test_runner)
        after_test(yellow { 'S' })
      end

      def failure(suite, test, test_runner)
        after_test(red { 'F' })
      end

      def error(suite, test, test_runner)
        after_test(red { 'E' })
      end

      def after_suites(suites, type)
        time = Time.now - runner.suites_start_time
        status_line = colored_for(suite_result) do
          "Finished %ss in %.6fs, %.4f tests/s, %.4f assertions/s." %
            [type, time, runner.test_count / time, runner.assertion_count / time]
        end

        puts
        puts
        puts status_line

        runner.test_results.each do |suite, tests|
          tests.each do |test, test_runner|
            if message = message_for(test_runner)
              puts
              print(colored_for(test_runner.result) { message })
            end
          end
        end

        puts
        puts(colored_for(suite_result) { status })
      end

      private

      def green(&block)
        @color ? ANSI::Code.green(&block) : yield
      end

      def yellow(&block)
        @color ? ANSI::Code.yellow(&block) : yield
      end

      def red(&block)
        @color ? ANSI::Code.red(&block) : yield
      end

      def colored_for(result, &block)
        case result
        when :failure, :error; red(&block)
        when :skip; yellow(&block)
        else green(&block)
        end
      end

      def suite_result
        if runner.failures > 0; :failure
        elsif runner.errors > 0; :error
        elsif runner.skips > 0; :skip
        else :pass
        end
      end

      def after_test(result)
        time = Time.now - runner.test_start_time

        print '%.2f s = ' % time if verbose?
        print result
        puts if verbose?
      end

      def location(exception)
        last_before_assertion = ''

        exception.backtrace.reverse_each do |s|
          break if s =~ /in .(assert|refute|flunk|pass|fail|raise|must|wont)/
          last_before_assertion = s
        end

        last_before_assertion.sub(/:in .*$/, '')
      end

      def message_for(test_runner)
        suite = test_runner.suite
        test = test_runner.test
        e = test_runner.exception

        case test_runner.result
        when :pass then nil
        when :skip
          if @detailed_skip
            "Skipped:\n#{test}(#{suite}) [#{location(e)}]:\n#{e.message}\n"
          end
        when :failure then "Failure:\n#{test}(#{suite}) [#{location(e)}]:\n#{e.message}\n"
        when :error
          bt = @backtrace_filter.filter(test_runner.exception.backtrace).join "\n    "
          "Error:\n#{test}(#{suite}):\n#{e.class}: #{e.message}\n    #{bt}\n"
        end
      end

      def status
        '%d tests, %d assertions, %d failures, %d errors, %d skips' %
          [runner.test_count, runner.assertion_count, runner.failures, runner.errors, runner.skips]
      end
    end
  end
end
