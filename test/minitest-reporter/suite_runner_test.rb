require 'test_helper'

module MiniTestReporterTest
  class SuiteRunnerTest < TestCase
    def setup
      @runner = MiniTest::SuiteRunner.new
      @reporter = add_reporter
    end
    
    test '#report' do
      assert_equal({}, @runner.report)
    end
    
    test '#reporters' do
      assert_equal [@reporter], @runner.reporters
      
      reporter2 = add_reporter
      assert_equal [@reporter, reporter2], @runner.reporters
    end
    
    test '#_run_anything with no suites' do
      stub_suites([])
      
      @reporter.expects(:before_suites).never
      @reporter.expects(:after_suites).never
      
      @runner._run_anything(:test)
      
      assert_equal 0, @runner.test_count
      assert_equal 0, @runner.assertion_count
      assert_instance_of Time, @runner.start_time
      assert_equal({}, @runner.report)
    end
    
    test '#_run_anything with suites' do
      suites = [Fixtures::PassTestFixture, Fixtures::SkipTestFixture]
      stub_suites(suites)
      
      @reporter.expects(:before_suites).with(suites, :test)
      @reporter.expects(:after_suites).with(suites, :test)
      
      @runner._run_anything(:test)
      
      assert_equal 3, @runner.test_count
      assert_equal 3, @runner.assertion_count
      assert_instance_of Time, @runner.start_time
      assert_equal :pass, @runner.report[Fixtures::PassTestFixture][:test_pass].result
      assert_equal :pass, @runner.report[Fixtures::PassTestFixture][:test_foo].result
      assert_equal :skip, @runner.report[Fixtures::SkipTestFixture][:test_skip].result
    end
    
    test '#_run_anything with a filter' do
      @runner.options[:filter] = '/foo/'
      stub_suites([Fixtures::PassTestFixture])
      
      @runner._run_anything(:test)
      assert_equal 2, @runner.assertion_count
    end
    
    test '#_run_suite without tests' do
      @reporter.expects(:before_suite).never
      @reporter.expects(:after_suite).never
      
      @runner._run_suite(Fixtures::EmptyTestFixture, [])
    end
    
    test '#_run_suite with tests' do
      @reporter.expects(:before_suite).with(Fixtures::PassTestFixture)
      @reporter.expects(:after_suite).with(Fixtures::PassTestFixture)
      
      @runner._run_suite(Fixtures::PassTestFixture, [:test_pass, :test_foo])
      
      assert_equal 3, @runner.assertion_count
      assert_instance_of Time, @runner.suite_start_time
    end
    
    test '#_run_suite with a suite .startup and .shutdown' do
      suite = Fixtures::SuiteCallbackTestFixture
      suite.expects(:startup)
      suite.expects(:shutdown)
      @runner._run_suite(suite, [:test_foo])
    end
    
    test '#_run_test with a passing test' do
      suite = Fixtures::PassTestFixture
      test = :test_pass
            
      @reporter.expects(:before_test).with(suite, test)
      @reporter.expects(:pass).with(suite, test, instance_of(MiniTest::TestRunner))
      
      @runner._run_test(suite, test)
      
      assert_equal 1, @runner.assertion_count
      assert_instance_of Time, @runner.test_start_time
      assert_equal :pass, @runner.report[suite][test].result
    end
    
    test '#_run_test with a skipped test' do
      suite = Fixtures::SkipTestFixture
      test = :test_skip
            
      @reporter.expects(:before_test).with(suite, test)
      @reporter.expects(:skip).with(suite, test, instance_of(MiniTest::TestRunner))
      
      @runner._run_test(suite, test)
      
      assert_equal 0, @runner.assertion_count
      assert_instance_of Time, @runner.test_start_time
      assert_equal :skip, @runner.report[suite][test].result
    end
    
    test '#_run_test with a failing test' do
      suite = Fixtures::FailureTestFixture
      test = :test_failure
            
      @reporter.expects(:before_test).with(suite, test)
      @reporter.expects(:failure).with(suite, test, instance_of(MiniTest::TestRunner))
      
      @runner._run_test(suite, test)
      
      assert_equal 0, @runner.assertion_count
      assert_instance_of Time, @runner.test_start_time
      assert_equal :failure, @runner.report[suite][test].result
    end
    
    test '#_run_test with an error test' do
      suite = Fixtures::ErrorTestFixture
      test = :test_error
      
      @reporter.expects(:before_test).with(suite, test)
      @reporter.expects(:error).with(suite, test, instance_of(MiniTest::TestRunner))
      
      @runner._run_test(suite, test)
      
      assert_equal 0, @runner.assertion_count
      assert_instance_of Time, @runner.test_start_time
      assert_equal :error, @runner.report[suite][test].result
    end
    
    test '#trigger' do
      reporter2 = add_reporter
      @reporter.expects(:before_suite).with(Fixtures::PassTestFixture)
      reporter2.expects(:before_suite).with(Fixtures::PassTestFixture)
      
      @runner.trigger(:before_suite, Fixtures::PassTestFixture)
    end
    
    private
    
    def add_reporter
      reporter = MiniTest::Reporter.new
      @runner.reporters << reporter
      reporter
    end
    
    def stub_suites(suites)
      MiniTest::Unit::TestCase.stubs(:test_suites).returns(suites)
    end
  end
end