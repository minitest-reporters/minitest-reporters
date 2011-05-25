require 'minitest/unit'

module MiniTest
  require 'minitest-reporter/reporter'
  require 'minitest-reporter/version'
  
  autoload :SuiteRunner, 'minitest-reporter/suite_runner'
  autoload :TestRunner, 'minitest-reporter/test_runner'
  
  module Reporters
    autoload :DefaultReporter, 'minitest-reporter/reporters/default_reporter'
    autoload :SpecReporter, 'minitest-reporter/reporters/spec_reporter'
    autoload :ProgressReporter, 'minitest-reporter/reporters/progress_reporter'
  end
end