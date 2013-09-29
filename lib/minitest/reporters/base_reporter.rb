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
        tests << test
      end

      protected

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
