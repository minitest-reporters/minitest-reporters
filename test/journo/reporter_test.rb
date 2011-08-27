require 'test_helper'

module MiniTestReportersTest
  class ReporterTest < TestCase
    def setup
      klass = Class.new do
        include MiniTest::Reporter
      end
      
      @reporter = klass.new
    end
    
    test 'callbacks' do
      [
        :before_suites, :after_suite, :before_suite, :after_suite, :before_test,
        :pass, :skip, :failure, :error
      ].each { |method| assert_respond_to @reporter, method }
    end
    
    test '#runner' do
      assert_kind_of MiniTest::Unit, @reporter.runner
    end
    
    test '#output' do
      assert_equal MiniTest::Unit.output, @reporter.output
    end
    
    test '#verbose?' do
      refute @reporter.verbose?
      
      begin
        @reporter.runner.verbose = true
        assert @reporter.verbose?
      ensure
        @reporter.runner.verbose = false
      end
    end
    
    test '#print' do
      @reporter.output.expects(:print).with('foo')
      @reporter.print('foo')
    end
    
    test '#puts' do
      @reporter.output.expects(:puts).with('foo')
      @reporter.puts('foo')
    end
  end
end