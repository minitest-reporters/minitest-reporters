module MiniTest
  module Reporters
    class BaseReporter < Minitest::StatisticsReporter
      def initialize(options={})
        super($stdout, options)
      end

      def add_defaults(defaults)
        self.options = defaults.merge(options)
      end

      protected

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
