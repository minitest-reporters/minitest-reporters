require 'test_helper'

module JournoTest
  class TestRunnerTest < TestCase
    def setup
      @suite = stub
      @test = :test_foo
      @runner = Journo::TestRunner.new(@suite, @test)
    end
    
    test '#suite' do
      assert_equal @suite, @runner.suite
    end
    
    test '#test' do
      assert_equal @test, @runner.test
    end
    
    test '#run with a passing test' do
      suite_instance = stub(:_assertions => 3)
      suite_instance.expects(:run).with(@runner).returns('.')
      @suite.stubs(:new).with(@test).returns(suite_instance)
      
      @runner.run
      
      assert_equal :pass, @runner.result
      assert_nil @runner.exception
      assert_equal 3, @runner.assertions
    end
    
    test '#run with an skipped test' do
      error = stub
      suite_instance = stub(:_assertions => 3)
      suite_instance.expects(:run).with(@runner).returns([:skip, error])
      @suite.stubs(:new).with(@test).returns(suite_instance)
      
      @runner.run
      
      assert_equal :skip, @runner.result
      assert_equal error, @runner.exception
      assert_equal 3, @runner.assertions
    end
    
    test '#run with a failing test' do
      error = stub
      suite_instance = stub(:_assertions => 3)
      suite_instance.expects(:run).with(@runner).returns([:failure, error])
      @suite.stubs(:new).with(@test).returns(suite_instance)
      
      @runner.run
      
      assert_equal :failure, @runner.result
      assert_equal error, @runner.exception
      assert_equal 3, @runner.assertions
    end
    
    test '#run with an errored test' do
      error = stub
      suite_instance = stub(:_assertions => 3)
      suite_instance.expects(:run).with(@runner).returns([:error, error])
      @suite.stubs(:new).with(@test).returns(suite_instance)
      
      @runner.run
      
      assert_equal :error, @runner.result
      assert_equal error, @runner.exception
      assert_equal 3, @runner.assertions
    end
    
    test '#puke with a skip' do
      skip = MiniTest::Skip.new
      result = @runner.puke(@suite, @test, skip)
      
      assert_equal [:skip, skip], result
    end
    
    test '#puke with a failure' do
      failure = MiniTest::Assertion.new
      result = @runner.puke(@suite, @test, failure)
      
      assert_equal [:failure, failure], result
    end
    
    test '#puke with an error' do
      error = RuntimeError.new
      result = @runner.puke(@suite, @test, error)
      
      assert_equal [:error, error], result
    end
  end
end