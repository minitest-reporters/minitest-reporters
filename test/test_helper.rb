require 'bundler/setup'
require 'minitest/autorun'
require 'mocha'
require 'test_declarative'
require 'journo'

module JournoTest
  require File.expand_path('../support/test_case', __FILE__)
  
  module Fixtures
    require File.expand_path('../support/fixtures/test_case_fixture', __FILE__)
    require File.expand_path('../support/fixtures/empty_test_fixture', __FILE__)
    require File.expand_path('../support/fixtures/error_test_fixture', __FILE__)
    require File.expand_path('../support/fixtures/failure_test_fixture', __FILE__)
    require File.expand_path('../support/fixtures/pass_test_fixture', __FILE__)
    require File.expand_path('../support/fixtures/skip_test_fixture', __FILE__)
    require File.expand_path('../support/fixtures/suite_callback_test_fixture', __FILE__)
  end
end

MiniTest::Unit.runner = Journo::SuiteRunner.new

# Testing the built-in reporters using automated unit testing would be extremely
# brittle. Consequently, there are no unit tests for them. Instead, uncomment
# the reporter that you'd like to test and run the full test suite. Make sure to
# try them with skipped, failing, and error tests as well!
# 
# Personally, I like the progress reporter. Make sure you don't change that line
# when you commit.
# 
# MiniTest::Unit.runner.reporters << Journo::Reporters::DefaultReporter.new
# MiniTest::Unit.runner.reporters << Journo::Reporters::SpecReporter.new
MiniTest::Unit.runner.reporters << Journo::Reporters::ProgressReporter.new