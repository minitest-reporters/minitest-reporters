require_relative "../../test_helper"

module MinitestReportersTest
  class JUnitReporterUnitTest < Minitest::Test
    def setup
      @reporter = Minitest::Reporters::JUnitReporter.new(
          "report",
          false,
          :base_apath => Dir.pwd
      )
      @result = Minitest::Result.new("test_name")
    end

    def test_relative_path
      path = Pathname.new(__FILE__).relative_path_from(Pathname.new(Dir.pwd)).to_s
      @result.source_location = [path, 10]
      relative_path = @reporter.get_relative_path(@result)
      assert_equal path, relative_path.to_s
    end
  end
end


