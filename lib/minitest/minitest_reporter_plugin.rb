require 'minitest'

module Minitest
  def self.plugin_minitest_reporter_options(opts, options)
  end

  def self.plugin_minitest_reporter_init(options)
    self.reporter.reporters.clear
    self.reporter.reporters.concat(MiniTest::Reporters.choose_reporters(MiniTest::Reporters::DefaultReporter.new(options), ENV, options))
  end

end
