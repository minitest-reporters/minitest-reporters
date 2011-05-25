require 'test_helper'

module MiniTestReporterTest
  class ReporterTest < TestCase
    def setup
      @reporter = MiniTest::Reporter.new
    end
    
    test 'callbacks' do
      [
        :before_suites, :after_suite, :before_suite, :after_suite, :before_test,
        :pass, :skip, :failure, :error
      ].each { |method| assert_respond_to @reporter, method }
    end
    
    test '#runner' do
      assert_instance_of MiniTest::Unit, @reporter.runner
    end
    
    test '#output' do
      assert_equal MiniTest::Unit.output, @reporter.output
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