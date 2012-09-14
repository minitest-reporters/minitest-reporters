require "test_helper"

module MiniTestReportersTest
  class ReportersTest < TestCase
    def test_chooses_the_rubymine_reporter_when_necessary
      # Rubymine reporter complains when RubyMine libs are not available, so
      # stub its #puts method out.
      stub(MiniTest::Unit.runner.output).puts

      reporters = Minitest::Reporters.choose_reporters [], { "RM_INFO" => "x" }
      assert_instance_of MiniTest::Reporters::RubyMineReporter, reporters[0]

      reporters = Minitest::Reporters.choose_reporters [], { "TEAMCITY_VERSION" => "x" }
      assert_instance_of MiniTest::Reporters::RubyMineReporter, reporters[0]
    end

    def test_chooses_the_textmate_reporter_when_necessary
      reporters = Minitest::Reporters.choose_reporters [], {"TM_PID" => "x"}
      assert_instance_of MiniTest::Reporters::RubyMateReporter, reporters[0]
    end

    def test_chooses_the_console_reporters_when_necessary
      reporters = Minitest::Reporters.choose_reporters [MiniTest::Reporters::SpecReporter.new], {}
      assert_instance_of MiniTest::Reporters::SpecReporter, reporters[0]
    end
  end
end
