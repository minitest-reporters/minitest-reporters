require_relative "../../test_helper"

module MinitestReportersTest
  class SpecReporterTest < Minitest::Test
    def setup
      @reporter = Minitest::Reporters::SpecReporter.new
      @test = Minitest::Test.new("")
      @test.time = 0
    end

    def test_removes_underscore_in_name_if_shoulda
      @test.name = "test_: Should foo"
      assert_output /test:/ do
        @reporter.io = $stdout
        @reporter.record(@test)
      end
    end

    def test_wont_modify_name_if_not_shoulda
      @test.name = "test_foo"
      assert_output /test_foo/ do
        @reporter.io = $stdout
        @reporter.record(@test)
      end
    end
  end
end
