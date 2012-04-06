require "minitest/unit"

module MiniTest
  autoload :Reporter, "minitest/reporter"
  autoload :SuiteRunner, "minitest/suite_runner"
  autoload :TestRunner, "minitest/test_runner"
  autoload :BacktraceFilter, "minitest/backtrace_filter"

  module Reporters
    require "minitest/reporters/version"

    autoload :DefaultReporter, "minitest/reporters/default_reporter"
    autoload :SpecReporter, "minitest/reporters/spec_reporter"
    autoload :ProgressReporter, "minitest/reporters/progress_reporter"
    autoload :RubyMateReporter, "minitest/reporters/ruby_mate_reporter"
    autoload :RubyMineReporter, "minitest/reporters/rubymine_reporter"
    autoload :GuardReporter, "minitest/reporters/guard_reporter"
  end
end
