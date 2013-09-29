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
    class ProgressReporter < BaseReporter
      include ANSI::Code

      INFO_PADDING = 2

      def initialize(options = {})
        super
        @detailed_skip = options.fetch(:detailed_skip, true)

        @progress = PowerBar.new(:msg => "0/#{count}")
        @progress.settings.tty.finite.output = lambda { |s| print(s) }
        @progress.settings.tty.finite.template.barchar = "="
        @progress.settings.tty.finite.template.padchar = " "
        @progress.settings.tty.finite.template.pre = "\e[1000D\e[?25l#{GREEN}"
        @progress.settings.tty.finite.template.post = CLEAR
      end

      def start
        super
        puts 'Started'
        puts
        show
      end

      def record(test)
        super
        if test.skipped?
          if @detailed_skip
            wipe
            print(yellow { 'SKIP' })
            print_test_with_time(test)
            puts
            puts
          end
          self.color = YELLOW unless color == RED
        elsif test.error? || test.failure
          wipe
          print(red { test.error? ? 'ERROR' : 'FAIL' })
          print_test_with_time(test)
          puts
          print_info(test.failures.last)
          puts

          self.color = RED
        end

        show
      end

      def report
        super
        @progress.close

        wipe
        puts
        puts('Finished in %.5fs' % total_time)
        print('%d tests, %d assertions, ' % [count, assertions])
        print(red { '%d failures, %d errors, ' } % [failures, errors])
        print(yellow { '%d skips' } % skips)
        puts
      end

      private

      def show
        return if count == 0

        @progress.show({
          :msg => "#{total_count}/#{count}",
          :done => results.count,
          :total => total_count,
        }, true)
      end

      def wipe
        @progress.wipe
      end

      def print_test_with_time(test)
        puts [test.name, test.location, total_time, ENDCODE].inspect
        print(" %s#%s (%.2fs)%s" % [test.name, test.location, total_time, ENDCODE])
      end

      def print_info(e)
        print pad("#{e.exception.class.to_s}: ")
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
