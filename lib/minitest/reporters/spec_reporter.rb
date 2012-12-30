require 'ansi/code'

module MiniTest
  module Reporters
    # Turn-like reporter that reads like a spec.
    #
    # Based upon TwP's turn (MIT License) and paydro's monkey-patch.
    #
    # @see https://github.com/TwP/turn turn
    # @see https://gist.github.com/356945 paydro's monkey-patch
    class SpecReporter
      include Reporter
      include ANSI::Code
      include RelativePosition

      def before_suites(suites, type)
        puts 'Started'
        puts
      end

      def after_suites(suites, type)
        total_time = Time.now - runner.suites_start_time

        puts('Finished in %.5fs' % total_time)
        print('%d tests, %d assertions, ' % [runner.test_count, runner.assertion_count])
        print(red { '%d failures, %d errors, ' } % [runner.failures, runner.errors])
        print(yellow { '%d skips' } % runner.skips)
        puts
      end

      def before_suite(suite)
        puts suite.name
      end

      def after_suite(suite)
        puts
      end

      def before_test(suite, test)
        print pad_test(test)
      end

      def pass(suite, test, test_runner)
        print(green { pad_mark('PASS') })
        print_time(test)
        puts
      end

      def skip(suite, test, test_runner)
        print(yellow { pad_mark('SKIP') })
        print_time(test)
        puts
      end

      def failure(suite, test, test_runner)
        print(red { pad_mark('FAIL') })
        print_time(test)
        puts
        print_info(test_runner.exception)
        puts
      end

      def error(suite, test, test_runner)
        print(red { pad_mark('ERROR') })
        print_time(test)
        puts
        print_info(test_runner.exception)
        puts
      end

      private

      def print_time(test)
        total_time = Time.now - (runner.test_start_time || Time.now)
        print(" (%.2fs)" % total_time)
      end

      def print_info(e)
        e.message.each_line { |line| print_with_info_padding(line) }

        trace = filter_backtrace(e.backtrace)
        trace.each { |line| print_with_info_padding(line) }
      end
    end
  end
end
