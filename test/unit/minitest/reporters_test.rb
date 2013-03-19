require_relative "../../test_helper"
require "stringio"

module MiniTestReportersTest
  class ReportersTest < TestCase
    def test_chooses_the_rubymine_reporter_when_necessary
      # Rubymine reporter complains when RubyMine libs are not available, so
      # stub its #puts method out.
      original_output = MiniTest::Unit.runner.output
      MiniTest::Unit.runner.send(:define_singleton_method, :output) { StringIO.new }

      reporters = Minitest::Reporters.choose_reporters [], { "RM_INFO" => "x" }
      assert_instance_of MiniTest::Reporters::RubyMineReporter, reporters[0]

      reporters = Minitest::Reporters.choose_reporters [], { "TEAMCITY_VERSION" => "x" }
      assert_instance_of MiniTest::Reporters::RubyMineReporter, reporters[0]
    ensure
      MiniTest::Unit.runner.send(:define_singleton_method, :output) { original_output }
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
