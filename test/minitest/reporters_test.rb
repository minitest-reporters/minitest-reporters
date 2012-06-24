require 'test_helper'

module MiniTestReportersTest
  class ReportersTest < TestCase
    test ".reporter sets up progressbar by default" do
      reporter = Minitest::Reporters.reporter :env => {}
      assert_equal MiniTest::Reporters::ProgressReporter, reporter.class
    end

    test ".reporter uses Rubymine when necessary" do
      MiniTest::Unit.runner.output.stubs(:puts) # Rubymine reporter complains when rubymine libs are not available

      reporter = Minitest::Reporters.reporter :env => {"RM_INFO" => "x"}
      assert_equal MiniTest::Reporters::RubyMineReporter, reporter.class

      reporter = Minitest::Reporters.reporter :env => {"TEAMCITY_VERSION" => "x"}
      assert_equal MiniTest::Reporters::RubyMineReporter, reporter.class
    end

    test ".reporter uses Textmate when necessary" do
      reporter = Minitest::Reporters.reporter :env => {"TM_PID" => "x"}
      assert_equal MiniTest::Reporters::RubyMateReporter, reporter.class
    end

    test ".reporter chooses passed :console reporter with empty env" do
      reporter = Minitest::Reporters.reporter :env => {}, :console => MiniTest::Reporters::SpecReporter.new
      assert_equal MiniTest::Reporters::SpecReporter, reporter.class
    end

    test ".reporter does not choose passed :console reporter with matching env" do
      reporter = Minitest::Reporters.reporter :env => {"TM_PID" => "x"}, :console => MiniTest::Reporters::SpecReporter.new
      assert_equal MiniTest::Reporters::RubyMateReporter, reporter.class
    end
  end
end
