require 'ansi/code'
require 'ruby-progressbar'

module Minitest
  module Reporters
    # Fuubar-like reporter with a progress bar.
    #
    # Based upon Jeff Kreefmeijer's Fuubar (MIT License) and paydro's
    # monkey-patch.
    #
    # @see https://github.com/jeffkreeftmeijer/fuubar Fuubar
    # @see https://gist.github.com/356945 paydro's monkey-patch
    class ProgressReporter < BaseReporter
      include RelativePosition
      include ANSI::Code

      PROGRESS_MARK = '='

      def initialize(options = {})
        super
        @detailed_skip = options.fetch(:detailed_skip, true)

        @progress = ProgressBar.create({
          total:          total_count,
          starting_at:    count,
          progress_mark:  green(PROGRESS_MARK),
          remainder_mark: ' ',
          format:         '  %C/%c: [%B] %p%% %a, %e',
          autostart:      false
        })
      end

      def start
        super
        puts 'Started'
        puts
        @progress.start
        @progress.total = total_count
        show
      end

      def record(test)
        super
        if (test.skipped? && @detailed_skip) || test.failure
          print "\e[0m\e[1000D\e[K"
          print_colored_status(test)
          print_test_with_time(test)
          puts
          print_info(test.failure, test.error?) if test.failure
          puts
        end

        if test.skipped? && color != "red"
          self.color = "yellow"
        elsif test.failure
          self.color = "red"
        end

        show
      end

      def report
        super
        @progress.finish

        puts
        puts('Finished in %.5fs' % total_time)
        print('%d tests, %d assertions, ' % [count, assertions])
        print(red { '%d failures, %d errors, ' } % [failures, errors])
        print(yellow { '%d skips' } % skips)
        puts
      end

      private

      def show
        @progress.increment unless count == 0
      end

      def print_test_with_time(test)
        puts [test.name, test.class, total_time].inspect
        print(" %s#%s (%.2fs)" % [test.name, test.class, total_time])
      end

      def color
        @color ||= "green"
      end

      def color=(color)
        @color = color
        @progress.progress_mark = send(color, PROGRESS_MARK)
      end
    end
  end
end
