require 'forwardable'

module MiniTest
  # Runner for MiniTest that supports reporters.
  #
  # Based upon Ryan Davis of Seattle.rb's MiniTest (MIT License).
  #
  # @see https://github.com/seattlerb/minitest MiniTest
  class ReporterRunner < Unit
    extend Forwardable

    attr_accessor :reporters
    attr_reader :test_results
    attr_reader :suites_start_time
    attr_reader :suite_start_time
    attr_reader :test_start_time

    def_delegator :@test_recorder, :assertion_count

    def initialize
      super
      self.reporters = []
      @test_results = {}
      @test_recorder = TestRecorder.new
    end

    def _run_suites(suites, type)
      @suites_start_time = Time.now
      count_tests!(suites, type)
      trigger_callback(:before_suites, suites, type)
      super(suites, type)
    ensure
      trigger_callback(:after_suites, suites, type)
    end

    def _run_suite(suite, type)
      @suite_start_time = Time.now
      trigger_callback(:before_suite, suite)
      super(suite, type)
    ensure
      trigger_callback(:after_suite, suite)
    end

    def before_test(suite, test)
      @test_start_time = Time.now
      trigger_callback(:before_test, suite, test)
    end

    def record(suite, test, assertions, time, exception)
      runner = TestRunner.new(suite,
                              test.to_sym,
                              assertions,
                              time,
                              exception)

      @test_results[suite] ||= {}
      @test_results[suite][test.to_sym] = runner
      @test_recorder.record(runner)

      # minitest-4.1.0 and earlier send record after all of the
      # callback hooks, so explicitly call after_test here after
      # recording.
      if Unit::VERSION <= "4.1.0"
        after_test(suite, test)
      end
    end

    def after_test(suite, test)
      # minitest-4.1.0 and earlier send this callback before
      # record, so runners will come back as nil.  In that case
      # we exit out and rely on the send in record above to call
      # us again when it is appropriate.

      runners = @test_recorder[suite, test.to_sym]
      return unless(runners)

      runners.each do |runner|
        trigger_callback(runner.result, suite, test.to_sym, runner)
      end
      trigger_callback(:after_test, suite, test.to_sym)
    end

    # Stub out the three IO methods used by the built-in reporter.
    def puts(*args); end
    def print(*args); end
    def status(io = output); end

    private

    def trigger_callback(callback, *args)
      reporters.each { |r| r.public_send(callback, *args) }
    end

    def count_tests!(suites, type)
      filter = options[:filter] || '/./'
      filter = Regexp.new $1 if filter =~ /\/(.*)\//

      @test_count = suites.inject(0) do |acc, suite|
        acc + suite.send("#{type}_methods").grep(filter).length
      end
    end
  end
end
