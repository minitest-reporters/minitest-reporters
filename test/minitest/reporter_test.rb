require 'test_helper'

module MiniTestReportersTest
  class ReporterTest < TestCase
    def setup
      klass = Class.new do
        include MiniTest::Reporter
      end

      @reporter = klass.new
    end

    def test_callbacks
      [
        :before_suites, :after_suite, :before_suite, :after_suite, :before_test,
        :pass, :skip, :failure, :error
      ].each { |method| assert_respond_to @reporter, method }
    end

    def test_runner
      assert_kind_of MiniTest::Unit, @reporter.runner
    end

    def test_output
      assert_equal MiniTest::Unit.output, @reporter.output
    end

    def test_verbose
      refute @reporter.verbose?

      begin
        @reporter.runner.verbose = true
        assert @reporter.verbose?
      ensure
        @reporter.runner.verbose = false
      end
    end

    def test_print
      mock(@reporter.output).print('foo')
      @reporter.print('foo')
    end

    def test_puts
      mock(@reporter.output).puts('foo')
      @reporter.puts('foo')
    end
  end
end
