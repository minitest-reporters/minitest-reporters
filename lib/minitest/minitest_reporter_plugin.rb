require 'minitest'

module Minitest
  def self.plugin_minitest_reporter_options(opts, options)
  end

  def self.plugin_minitest_reporter_init(options)
    self.reporter.reporters.clear
    reporters = initialize_reporters(options)
    self.reporter.reporters.concat(MiniTest::Reporters.choose_reporters(reporters, ENV, options))
  end

  def self.initialize_reporters(options)
    unless Minitest.constants.include?(:Reporters)
      require 'minitest/reporters/default_reporter'
    end
    Minitest::Reporters.constants.map do |reporter|
      klass = Minitest::Reporters.const_get(reporter)
      klass.new(options.merge(:total_tests => total_tests))
    end
  end

  def self.total_tests
    Runnable.runnables.map(&:runnable_methods).flatten.count
  end

end
