module MiniTest
  # Runner for MiniTest that supports reporters.
  #
  # Based upon Ryan Davis of Seattle.rb's MiniTest (MIT License).
  #
  # @see https://github.com/seattlerb/minitest MiniTest
  class ReporterRunner < Unit
    attr_accessor :suites_start_time, :test_start_time, :reporters, :test_results

    alias_method :suite_start_time, :start_time

    def initialize
      super
      self.reporters = []
      self.test_results = {}
    end

    def _run_suites(suites, type)
      self.suites_start_time = Time.now
      count_tests!(suites, type)
      trigger_callback(:before_suites, suites, type)
      super(suites, type)
    ensure
      trigger_callback(:after_suites, suites, type)
    end

    def _run_suite(suite, type)
      trigger_callback(:before_suite, suite)
      self.start_time = Time.now
      super(suite, type)
    ensure
      trigger_callback(:after_suite, suite)
    end

    def before_test(suite, test)
      self.test_start_time = Time.now
      trigger_callback(:before_test, suite, test)
    end

    def record(suite, test, assertions, time, exception)
      self.assertion_count += assertions

      result = case exception
      when nil then :pass
      when Skip then :skip
      when Assertion then :failure
      else :error
      end

      test_runner = TestRunner.new(
        suite,
        test.to_sym,
        assertions,
        time,
        result,
        exception
      )

      test_results[suite] ||= {}
      test_results[suite][test.to_sym] = test_runner
      trigger_callback(result, suite, test, test_runner)
    end

    def puts(*args)
    end

    def print(*args)
    end

    def status(io = output)
    end

    private

    def trigger_callback(callback, *args)
      reporters.each do |reporter|
        reporter.public_send(callback, *args)
      end
    end

    def count_tests!(suites, type)
      filter = options[:filter] || '/./'
      filter = Regexp.new $1 if filter =~ /\/(.*)\//
      self.test_count = suites.inject(0) do |acc, suite|
        acc + suite.send("#{type}_methods").grep(filter).length
      end
    end
  end
end
