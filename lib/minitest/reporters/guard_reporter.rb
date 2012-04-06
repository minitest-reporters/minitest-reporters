begin
  require 'guard/minitest/notifier'
rescue LoadError
  puts "You need guard-minitest to use this reporter"
  exit 1
end

module MiniTest
  module Reporters

    class GuardReporter
      include MiniTest::Reporter

      def after_suites(*args)
        duration = Time.now - runner.start_time
        ::Guard::MinitestNotifier.notify(runner.test_count, runner.assertion_count,
                                         runner.failures, runner.errors,
                                         runner.skips, duration)
      end
    end
  end
end
