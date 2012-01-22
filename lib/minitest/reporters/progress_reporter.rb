require 'ansi'
require 'progressbar'

module MiniTest
  module Reporters
    # Fuubar-like reporter with a progress bar.
    #
    # Based upon Jeff Kreefmeijer's Fuubar (MIT License) and paydro's
    # monkey-patch.
    #
    # @see https://github.com/jeffkreeftmeijer/fuubar Fuubar
    # @see https://gist.github.com/356945 paydro's monkey-patch
    class ProgressReporter
      include MiniTest::Reporter
      include ANSI::Code

      INFO_PADDING = 2

      def initialize(backtrace_filter = MiniTest::BacktraceFilter.default_filter)
        @backtrace_filter = backtrace_filter
      end

      def before_suites(suites, type)
        puts 'Started'
        puts

        @color = GREEN
        @finished_count = 0
        @progress = ProgressBar.new("0/#{runner.test_count}", runner.test_count, runner.output)
        @progress.bar_mark = '='
      end

      def increment
        with_color do
          @finished_count += 1
          @progress.instance_variable_set('@title', "#{@finished_count}/#{runner.test_count}")
          @progress.inc
        end
      end

      def pass(suite, test, test_runner)
        increment
      end

      def skip(suite, test, test_runner)
        @color = YELLOW unless @color == RED
        print(yellow { 'SKIP' })
        print_test_with_time(suite, test)
        puts
        puts
        increment
      end

      def failure(suite, test, test_runner)
        @color = RED
        print(red { 'FAIL' })
        print_test_with_time(suite, test)
        puts
        print_info(test_runner.exception)
        puts
        increment
      end

      def error(suite, test, test_runner)
        @color = RED
        print(red { 'ERROR' })
        print_test_with_time(suite, test)
        puts
        print_info(test_runner.exception)
        puts
        increment
      end

      def after_suites(suites, type)
        with_color { @progress.finish }

        total_time = Time.now - runner.start_time

        puts
        puts('Finished in %.5fs' % total_time)
        print('%d tests, %d assertions, ' % [runner.test_count, runner.assertion_count])
        print(red { '%d failures, %d errors, ' } % [runner.failures, runner.errors])
        print(yellow { '%d skips' } % runner.skips)
        puts
      end

      private

      def print_test_with_time(suite, test)
        total_time = Time.now - runner.test_start_time
        print(" #{suite}##{test} (%.2fs)#{clr}" % total_time)
      end

      def print_info(e)
        e.message.each_line { |line| puts pad(line) }

        trace = @backtrace_filter.filter(e.backtrace)
        trace.each { |line| puts pad(line) }
      end

      def pad(str)
        ' ' * INFO_PADDING + str
      end

      def with_color
        print @color
        yield
        print CLEAR
      end
    end
  end
end
