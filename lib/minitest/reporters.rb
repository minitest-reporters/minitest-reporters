require "minitest/unit"

module MiniTest
  require "minitest/reporter"
  require "minitest/reporter_runner"
  require "minitest/before_test_hook"
  require "minitest/test_runner"
  require "minitest/backtrace_filter"

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
      include_hook!
      runner = ReporterRunner.new
      runner.reporters = choose_reporters(console_reporters, env)
      Unit.runner = runner
    end

    def self.include_hook!
      if Unit::VERSION >= "3.3.0"
        Unit::TestCase.send(:include, BeforeTestHook)
      else
        Unit::TestCase.send(:define_method, :before_setup) do
          BeforeTestHook.before_test(self)
        end
      end
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
