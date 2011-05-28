require 'minitest/unit'

module Journo
  require 'journo/version'
  
  autoload :Reporter, 'journo/reporter'
  autoload :SuiteRunner, 'journo/suite_runner'
  autoload :TestRunner, 'journo/test_runner'
  
  module Reporters
    autoload :DefaultReporter, 'journo/reporters/default_reporter'
    autoload :SpecReporter, 'journo/reporters/spec_reporter'
    autoload :ProgressReporter, 'journo/reporters/progress_reporter'
  end
end