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
        options = {
          :show_order  => :after,
          :show_time   => true,
          :show_status => true
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
        # if options[:show_order] == :before
        #    print_colored_status(test) if options[:show_status]
        #    test_name = test.name.gsub(/^test_(\d+_)?/, '  ')
        #    print(test_name)
        #    unless test.time.nil?
        #      color = test.time > 0.1 ? :red : :white
        #      print(send(color) { "  -  (%.2fs)" } % test.time) if options[:show_time]
        #    end
        #  else
          test_name = test.name.gsub(/^test_: /, 'test:')
          print pad_test(test_name)
          print_colored_status(test)
          print(" (%.2fs)" % test.time) unless test.time.nil?
        # end
        puts
        if !test.skipped? && test.failure
          print_info(test.failure)
          puts
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
