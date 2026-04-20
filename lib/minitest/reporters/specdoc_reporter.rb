module Minitest
  module Reporters
    # Turn-like reporter that reads like a spec with improved formatting options.
    #
    # Based upon SpecReporter and TwP's turn (MIT License) and paydro's monkey-patch.
    #
    # @see https://github.com/TwP/turn turn
    # @see https://gist.github.com/356945 paydro's monkey-patch
    class SpecdocReporter < BaseReporter
      include ANSI::Code
      include RelativePosition

      def initialize(options = {})
        super
        options = {
          :show_order => :after,
          :show_time => true,
          :show_status => true,
        }.merge(options)
        @options = options
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
        test_name = test.name.sub(/^test_(\d+_|:\s)?/, '  ')
        test_name.strip! if options[:show_order] == :after
        unless test.time.nil?
          color = test.time > 0.1 ? :red : :white
          test_time = send(color) { "(%.2fs)" } % test.time
        end

        if options[:show_order] == :before
          print_colored_status(test) if options[:show_status]
          print(test_name)
          print("  -  #{test_time}") if options[:show_time]
        else # :after
          print pad_test(test_name)
          print_colored_status(test) if options[:show_status]
          print(" #{test_time}") if options[:show_time]
        end
        puts
        return unless !test.skipped? && test.failure

        print_info(test.failure)
        puts
      end

      protected

      def before_suite(suite)
        puts suite
      end

      def after_suite(_suite)
        puts
      end
    end
  end
end
