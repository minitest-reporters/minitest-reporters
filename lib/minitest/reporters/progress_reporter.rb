require 'ansi/code'
require 'powerbar'

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
      include Reporter
      include ANSI::Code

      INFO_PADDING = 2

      def initialize(options = {})
        @detailed_skip = options.fetch(:detailed_skip, true)

        @progress = PowerBar.new(:msg => "0/#{runner.test_count}")
        @progress.settings.tty.finite.output = lambda { |s| print(s) }
        @progress.settings.tty.finite.template.barchar = "="
        @progress.settings.tty.finite.template.padchar = " "
        @progress.settings.tty.finite.template.pre = "\e[1000D\e[?25l#{GREEN}"
        @progress.settings.tty.finite.template.post = CLEAR
      end

      def before_suites(suites, type)
        puts 'Started'
        puts

        @finished_count = 0
      end

      def increment
        @finished_count += 1
        @progress.show({
          :msg => "#{@finished_count}/#{runner.test_count}",
          :done => @finished_count,
          :total => runner.test_count,
        }, true)
      end

      def pass(suite, test, test_runner)
        increment
      end

      def skip(suite, test, test_runner)
        if @detailed_skip
          wipe
          print(yellow { 'SKIP' })
          print_test_with_time(suite, test)
          puts
          puts
        end

        self.color = YELLOW unless color == RED
        increment
      end

      def failure(suite, test, test_runner)
        wipe
        print(red { 'FAIL' })
        print_test_with_time(suite, test)
        puts
        print_info(test_runner.exception)
        puts

        self.color = RED
        increment
      end

      def error(suite, test, test_runner)
        wipe
        print(red { 'ERROR' })
        print_test_with_time(suite, test)
        puts
        print_info(test_runner.exception)
        puts

        self.color = RED
        increment
      end

      def after_suites(suites, type)
        @progress.close

        total_time = Time.now - runner.suites_start_time

        wipe
        puts
        puts('Finished in %.5fs' % total_time)
        print('%d tests, %d assertions, ' % [runner.test_count, runner.assertion_count])
        print(red { '%d failures, %d errors, ' } % [runner.failures, runner.errors])
        print(yellow { '%d skips' } % runner.skips)
        puts
      end

      private

      def wipe
        @progress.wipe
      end

      def print_test_with_time(suite, test)
        total_time = Time.now - (runner.test_start_time || Time.now)
        print(" %s#%s (%.2fs)%s" % [suite, test, total_time, clr])
      end

      def print_info(e)
        e.message.each_line { |line| puts pad(line) }

        trace = filter_backtrace(e.backtrace)
        trace.each { |line| puts pad(line) }
      end

      def pad(str)
        ' ' * INFO_PADDING + str
      end

      def color
        @color ||= GREEN
      end

      def color=(color)
        @color = color
        @progress.scope.template.pre = "\e[1000D\e[?25l#{@color}"
      end
    end
  end
end
