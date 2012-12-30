require 'ansi/code'

module MiniTest
  module Reporters
    # Simple reporter designed for RubyMate.
    class RubyMateReporter
      include Reporter

      INFO_PADDING = 2

      def before_suites(suites, type)
        puts 'Started'
        puts
      end

      def skip(suite, test, test_runner)
        print 'SKIP'
        print_test_with_time(suite, test)
        puts
        puts
      end

      def failure(suite, test, test_runner)
        print 'FAIL'
        print_test_with_time(suite, test)
        puts
        print_info(test_runner.exception)
        puts
      end

      def error(suite, test, test_runner)
        print 'ERROR'
        print_test_with_time(suite, test)
        puts
        print_info(test_runner.exception)
        puts
      end

      def after_suites(suites, type)
        total_time = Time.now - runner.suites_start_time

        puts
        puts('Finished in %.5fs' % total_time)
        print('%d tests, %d assertions, ' % [runner.test_count, runner.assertion_count])
        print('%d failures, %d errors, ' % [runner.failures, runner.errors])
        print('%d skips' % runner.skips)
        puts
      end

      private

      def print_test_with_time(suite, test)
        total_time = Time.now - (runner.test_start_time || Time.now)
        print(" #{suite}##{test} (%.2fs)" % total_time)
      end

      def print_info(e)
        e.message.each_line { |line| puts pad(line) }

        trace = filter_backtrace(e.backtrace)
        trace.each { |line| puts pad(line) }
      end

      def pad(str)
        ' ' * INFO_PADDING + str
      end
    end
  end
end
