module Minitest
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

      def initialize(options = {})
        super
        @fast_fail = options.fetch(:fast_fail, false)
      end

      def start
        super
        puts('Started with run options %s' % options[:args])
        puts
      end

      def report
        super
        puts('Finished in %.5fs' % total_time)
        print('%d tests, %d assertions, ' % [count, assertions])
        color = failures.zero? && errors.zero? ? :green : :red
        print(send(color) { '%d failures, %d errors, ' } % [failures, errors])
        print(yellow { '%d skips' } % skips)
        puts
      end

      def record(test)
        super
        print pad_test(test.name)
        print_colored_status(test)
        print(" (%.2fs)" % test.time)
        puts
        if !test.skipped? && test.failure
          print_info(test.failure)
          puts
          if @fast_fail
            report
            exit 1
          end
        end
      end

      protected

      def before_suite(suite)
        puts suite
      end

      def after_suite(suite)
        puts
      end
    end
  end
end
