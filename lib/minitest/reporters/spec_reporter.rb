require 'ansi/code'

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

      def start
        super
        puts('Started with run options %s' % options[:args])
        puts
      end

      def report
        super
        print_error_summary
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
        end
      end

      protected

      BASE_OFFSET = 2

      # Prints an error summary at the end of the test suite, excluding skipped tests.
      def print_error_summary
        padding   = errors.size.to_s.length + BASE_OFFSET
        # `results` contains only Errors and Failures
        results.reject(&:skipped?).each_with_index do |error, index|
          lines = error.to_s.split("\n")
          first_line = lines.shift(2).join(" ")
          io.puts "\n%#{padding}d) %s" % [index + 1, first_line]
          lines.each do |line|
            io.puts (" " * (padding+5)) + line
          end
        end
        io.puts
      end

      def before_suite(suite)
        puts suite
      end

      def after_suite(suite)
        puts
      end
    end
  end
end
