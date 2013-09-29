require 'ansi/code'

module MiniTest
  module Reporters
    # Turn-like reporter that reads like a spec.
    #
    # Based upon TwP's turn (MIT License) and paydro's monkey-patch.
    #
    # @see https://github.com/TwP/turn turn
    # @see https://gist.github.com/356945 paydro's monkey-patch
    class SpecReporter < BaseReporter
      include ANSI::Code
      include RelativePosition

      def start
        super
        puts 'Started'
        puts
      end

      def report
        super
        puts('Finished in %.5fs' % total_time)
        print('%d tests, %d assertions, ' % [count, assertions])
        print(red { '%d failures, %d errors, ' } % [failures, errors])
        print(yellow { '%d skips' } % skips)
        puts
      end

      def record(test)
        super
        verb = if test.passed? # TODO make normal thingy return fail
          'PASS'
        elsif test.skipped?
          'SKIP'
        elsif test.error?
          'ERROR'
        else
          'FAIL'
        end

        puts test.class
        print pad_test(test)
        print(green { pad_mark( verb ) })
        print(" (%.2fs)" % test.time)
        puts
        if test.failure
          print_info(test.failure)
          puts
        end
      end

      protected

      def after_suite(test)
        puts
      end
    end
  end
end
