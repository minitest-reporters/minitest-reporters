require 'test_helper'

module MiniTestReportersTest
  class ReportersTest < TestCase
    test "chooses the Rubymine reporter when necessary" do
      # Rubymine reporter complains when RubyMine libs are not available, so
      # stub its #puts method out.
      MiniTest::Unit.runner.output.stubs(:puts) 

      reporters = Minitest::Reporters.choose_reporters [], { "RM_INFO" => "x" }
      assert_instance_of MiniTest::Reporters::RubyMineReporter, reporters[0]

      reporters = Minitest::Reporters.choose_reporters [], { "TEAMCITY_VERSION" => "x" }
      assert_instance_of MiniTest::Reporters::RubyMineReporter, reporters[0]
    end

    test "chooses the TextMate reporter when necessary" do
      reporters = Minitest::Reporters.choose_reporters [], {"TM_PID" => "x"}
      assert_instance_of MiniTest::Reporters::RubyMateReporter, reporters[0]
    end

    test "chooses the console reporters when necessary" do
      reporters = Minitest::Reporters.choose_reporters [MiniTest::Reporters::SpecReporter.new], {}
      assert_instance_of MiniTest::Reporters::SpecReporter, reporters[0]
    end
  end
end
