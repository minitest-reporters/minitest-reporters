module MiniTest
  class SuiteRunner < Unit
    class << self
      attr_writer :reporters
      
      def reporters
        @reporters ||= []
      end
    end
    
    attr_accessor :suite_start_time, :test_start_time
    
    def initialize
      self.report = {}
      self.errors = 0
      self.failures = 0
      self.skips = 0
      self.test_count = 0
      self.assertion_count = 0
      self.verbose = false
    end
    
    def _run_anything(type)
      self.start_time = Time.now
      
      suites = suites_of_type(type)
      tests = suites.inject({}) do |acc, suite|
        acc[suite] = filtered_tests(suite, type)
        acc
      end
      
      self.test_count = tests.inject(0) { |acc, suite| acc + suite[1].length }
      
      if test_count > 0
        trigger(:before_suites, suites)
        fix_sync { _run_suites(suites, type) }
        trigger(:after_suites, suites)
      end
    end
    
    def _run_suite(suite, type)
      tests = filtered_tests(suite, type)
      
      unless tests.empty?
        self.suite_start_time = Time.now
        trigger(:before_suite, suite)
        _run_tests(suite, tests)
        trigger(:after_suite, suite)
      end
    end
    
    def _run_tests(suite, tests)
      suite.startup if suite.respond_to?(:startup)
      tests.each { |test| _run_test(suite, test) }
    ensure
      suite.shutdown if suite.respond_to?(:shutdown)
    end
    
    def _run_test(suite, test)
      self.test_start_time = Time.now
      trigger(:before_test, suite, test)
      
      test_runner = TestRunner.new(suite, test)
      test_runner.run
      add_test_result(suite, test, test_runner)
      
      trigger(test_runner.result, suite, test, test_runner)
    end
    
    def trigger(callback, *args)
      self.class.reporters.each { |reporter| reporter.send(callback, *args) }
    end
    
    private
    
    def filtered_tests(suite, type)
      filter = options[:filter] || '/./'
      filter = Regexp.new($1) if filter =~ /\/(.*)\//
      suite.send("#{type}_methods").grep(filter)
    end
    
    def suites_of_type(type)
      TestCase.send("#{type}_suites")
    end
    
    def add_test_result(suite, test, test_runner)
      self.report[suite] ||= {}
      self.report[suite][test] = test_runner
      
      self.assertion_count += test_runner.assertions
      
      case test_runner.result
      when :skip then self.skips += 1
      when :failure then self.failures += 1
      when :error then self.errors += 1
      end
    end
    
    def fix_sync
      sync = output.respond_to?(:'sync=') # stupid emacs
      old_sync, output.sync = output.sync, true if sync
      yield
      output.sync = old_sync if sync
    end
  end
end