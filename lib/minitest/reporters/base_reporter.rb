module MiniTest
  module Reporters
    class BaseReporter < Minitest::StatisticsReporter
      attr_accessor :total_count
      attr_accessor :tests

      def initialize(options={})
        super($stdout, options)
        self.tests = []
      end

      def add_defaults(defaults)
        self.options = defaults.merge(options)
      end

      def record(test)
        super
        last_test = tests.last
        if last_test.class != test.class
          after_suite(test.class) if last_test
          before_suite(test.class)
        end
        tests << test
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
        elsif test.failure
          :failure
        elsif test.skipped?
          :skip
        else
          :pass
        end
      end

      def total_time
        super || Time.now - start_time
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
    end
  end
end
