require "minitest/unit"

module MiniTest
  require "minitest/relative_position"
  #require "minitest/reporter_runner"
  #require "minitest/around_test_hooks"
  #require "minitest/test_runner"
  #require "minitest/test_recorder"
  require "minitest/extensible_backtrace_filter"

  module Reporters
    require "minitest/reporters/version"

    autoload :BaseReporter, "minitest/reporters/base_reporter"
    autoload :DefaultReporter, "minitest/reporters/default_reporter"
    autoload :SpecReporter, "minitest/reporters/spec_reporter"
    autoload :ProgressReporter, "minitest/reporters/progress_reporter"
    autoload :RubyMateReporter, "minitest/reporters/ruby_mate_reporter"
    autoload :RubyMineReporter, "minitest/reporters/rubymine_reporter"
    autoload :JUnitReporter, "minitest/reporters/junit_reporter"

    class << self
      attr_accessor :reporters
    end

    def self.use!(console_reporters = ProgressReporter.new, env = ENV, backtrace_filter = ExtensibleBacktraceFilter.default_filter)
      use_runner!(console_reporters, env)
      Minitest.backtrace_filter = backtrace_filter

      #unless defined?(@@loaded)
      #  use_around_test_hooks!
      #  use_parallel_length_method!
      #  use_old_activesupport_fix!
      #end

      @@loaded = true
    end

    def self.use_runner!(console_reporters, env)
      self.reporters = choose_reporters(console_reporters, env)
    end

    def self.use_around_test_hooks!
      Unit::TestCase.class_eval do
        def run_with_hooks(runner)
          AroundTestHooks.before_test(self)
          result = run_without_hooks(runner)
          AroundTestHooks.after_test(self)
          result
        end

        alias_method :run_without_hooks, :run
        alias_method :run, :run_with_hooks
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

    def self.use_parallel_length_method!
      if Unit::VERSION >= "4.2.0"
        require "minitest/parallel_each"

        ParallelEach.send(:define_method, :length) do
          @queue.length
        end
      end
    end

    def self.use_old_activesupport_fix!
      if defined?(ActiveSupport::VERSION) && ActiveSupport::VERSION::MAJOR < 4
        require "minitest/old_activesupport_fix"
      end
    end
  end
end
