module MiniTest
  module Reporters
    class BaseReporter < Minitest::StatisticsReporter
      attr_accessor :total_count

      def initialize(options={})
        super($stdout, options)
      end

      def add_defaults(defaults)
        self.options = defaults.merge(options)
      end

      protected

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
