module Minitest
  class << self
    def plugin_minitest_reporter_init(options)
      if defined?(MiniTest::Reporters) && MiniTest::Reporters.reporters
        reporter.reporters = MiniTest::Reporters.reporters + guard_reporter
        reporter.reporters.each do |reporter|
          reporter.io = options[:io]
          reporter.add_defaults(options.merge(:total_count => Minitest::Runnable.runnables.map(&:runnable_methods).flatten.count))
        end
      end
    end

    private

    def guard_reporter
      Array(reporter.reporters.detect { |r| r.class.name == "Guard::Minitest::Reporter" })
    end
  end
end
