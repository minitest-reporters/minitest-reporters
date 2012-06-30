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
    autoload :JUnitReporter, "minitest/reporters/junit_reporter"

    def self.use!(console_reporters = ProgressReporter.new, env = ENV)
      runner = SuiteRunner.new
      runner.reporters = choose_reporters(console_reporters, env)
      Unit.runner = runner
    end

    def self.choose_reporters(console_reporters, env)
      if env["TM_PID"]
        [RubyMateReporter.new]
      elsif env["RM_INFO"] || env["TEAMCITY_VERSION"]
        [RubyMineReporter.new]
      else
        Array(console_reporters)
      end
    end
  end
end
