module Minitest
  def self.plugin_minitest_reporter_init(options)
    if defined?(MiniTest::Reporters) && MiniTest::Reporters.reporters
      self.reporter.reporters = MiniTest::Reporters.reporters
      self.reporter.reporters.each do |reporter|
        reporter.io = options[:io]
        reporter.add_defaults(options.merge(:total_count => Minitest::Runnable.runnables.map(&:runnable_methods).flatten.count))
      end
    end
  end
end
