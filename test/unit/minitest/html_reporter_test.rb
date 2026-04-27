require_relative "../../test_helper"

module MinitestReportersTest
  class HtmlReporterTest < Minitest::Test
    def test_total_time_calculation
      @reporter = Minitest::Reporters::HtmlReporter.new
      @reporter.stub(:total_time, 2492.8) do
        hms = @reporter.send(:total_time_to_hms)
        assert_equal "0h41m33s", hms
      end
    end
  end
end

