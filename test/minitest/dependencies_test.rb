require 'test_helper'

module MiniTestReportersTest
  class ReporterTest < TestCase
    def setup
      klass = Class.new do
        include MiniTest::Reporter
      end

      @reporter = klass.new
    end

    test 'ProgressBar' do

      if defined?(::ProgressBar) == 'constant' && ProgressBar.class == Class
        fail "should not have a ::ProgressBar class polluting the top-level namespace"
      end

    end

  end

end

