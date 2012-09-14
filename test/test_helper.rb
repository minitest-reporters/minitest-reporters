require 'bundler/setup'
require 'minitest/autorun'
require 'rr'
require 'minitest/reporters'

module MiniTestReportersTest
  class TestCase < MiniTest::Unit::TestCase
    include RR::Adapters::MiniTest
  end
end

# Testing the built-in reporters using automated unit testing would be extremely
# brittle. Consequently, there are no unit tests for them. Instead, uncomment
# the reporter that you'd like to test and run the full test suite. Make sure to
# try them with skipped, failing, and error tests as well!

MiniTest::Reporters.use!
# MiniTest::Reporters.use! MiniTest::Reporters::DefaultReporter.new
# MiniTest::Reporters.use! MiniTest::Reporters::SpecReporter.new
# MiniTest::Reporters.use! MiniTest::Reporters::ProgressReporter.new(:detailed_skip => false)
# MiniTest::Reporters.use! MiniTest::Reporters::RubyMateReporter.new
# MiniTest::Reporters.use! MiniTest::Reporters::RubyMineReporter.new
# MiniTest::Reporters.use! MiniTest::Reporters::GuardReporter.new
# MiniTest::Reporters.use! MiniTest::Reporters::JUnitReporter.new
