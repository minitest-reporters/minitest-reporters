module Minitest
  #def self.plugin_minitest_reporter_options(opts, options)
  #end

  def self.plugin_minitest_reporter_init(options)
    if defined?(MiniTest::Reporters) && MiniTest::Reporters.reporters
      self.reporter.reporters = MiniTest::Reporters.reporters
      self.reporter.reporters.each do |reporter|
        reporter.io = options[:io]
        reporter.add_defaults(options)
      end
    end
  end

  def self.initialize_reporters(options)
    puts "ZZZ"
  #  unless Minitest.constants.include?(:Reporters)
  #    require 'minitest/reporters/default_reporter'
  #  end
  #  Minitest::Reporters.constants.map do |reporter|
  #    klass = Minitest::Reporters.const_get(reporter)
  #    klass.new(options.merge(:total_tests => total_tests))
  #  end
  end
  #
  #def self.total_tests
  #  Runnable.runnables.map(&:runnable_methods).flatten.count
  #end
end
