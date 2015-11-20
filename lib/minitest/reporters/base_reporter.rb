module Minitest
  module Reporters
    class BaseReporter < Minitest::StatisticsReporter
      attr_accessor :tests

      def initialize(options={})
        super($stdout, options)
        self.tests = []
      end

      def add_defaults(defaults)
        self.options = defaults.merge(options)
      end

      # called by our own before hooks
      def before_test(test)
        last_test = tests.last
        if last_test.class != test.class
          after_suite(last_test.class) if last_test
          before_suite(test.class)
        end
      end

      def record(test)
        super
        tests << test
      end

      # called by our own after hooks
      def after_test(test)
      end

      def report
        super
        after_suite(tests.last.class)
      end

      protected

      def after_suite(test)
      end

      def before_suite(test)
      end

      def result(test)
        if test.error?
          :error
        elsif test.skipped?
          :skip
        elsif test.failure
          :fail
        else
          :pass
        end
      end

      def print_colored_status(test)
        if test.passed?
          print(green { pad_mark( result(test).to_s.upcase ) })
        elsif test.skipped?
          print(yellow { pad_mark( result(test).to_s.upcase ) })
        else
          print(red { pad_mark( result(test).to_s.upcase ) })
        end
      end

      def total_time
        super || Minitest::Reporters.clock_time - start_time
      end

      def total_count
        options[:total_count]
      end

      def filter_backtrace(backtrace)
        Minitest.filter_backtrace(backtrace)
      end

      def puts(*args)
        io.puts(*args)
      end

      def print(*args)
        io.print(*args)
      end

      def print_info(e, name=true)
        print "#{e.exception.class.to_s}: " if name
        e.message.each_line { |line| print_with_info_padding(line) }

        # When e is a Minitest::UnexpectedError, the filtered backtrace is already part of the message printed out
        # by the previous line. In that case, and that case only, skip the backtrace output.
        unless e.is_a?(MiniTest::UnexpectedError)
          trace = filter_backtrace(e.backtrace)
          trace.each { |line| print_with_info_padding(line) }
        end
      end
    end
  end
end
