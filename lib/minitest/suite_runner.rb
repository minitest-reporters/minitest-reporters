module MiniTest
  # Runner for MiniTest suites.
  # 
  # This is a heavily refactored version of the built-in MiniTest runner. It's
  # about the same speed, from what I can tell, but is significantly easier to
  # extend.
  # 
  # Based upon Ryan Davis of Seattle.rb's MiniTest (MIT License).
  # 
  # @see https://github.com/seattlerb/minitest MiniTest
  class SuiteRunner < MiniTest::Unit
    attr_accessor :suite_start_time, :test_start_time, :reporters
    
    def initialize
      self.report = {}
      self.errors = 0
      self.failures = 0
      self.skips = 0
      self.test_count = 0
      self.assertion_count = 0
      self.verbose = false
      self.reporters = []
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
        trigger(:before_suites, suites, type)
        
        fix_sync do
          suites.each { |suite| _run_suite(suite, tests[suite]) }
        end
        
        trigger(:after_suites, suites, type)
      end
    end
    
    def _run_suite(suite, tests)
      unless tests.empty?
        begin
          self.suite_start_time = Time.now
          
          trigger(:before_suite, suite)
          suite.startup if suite.respond_to?(:startup)
          
          tests.each { |test| _run_test(suite, test) }
        ensure
          suite.shutdown if suite.respond_to?(:shutdown)
          trigger(:after_suite, suite)
        end
      end
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
      reporters.each { |reporter| reporter.send(callback, *args) }
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
      self.report[suite][test.to_sym] = test_runner
      
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