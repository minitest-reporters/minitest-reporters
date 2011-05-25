module MiniTestReporterTest
  module Fixtures
    class ErrorTestFixture < TestCaseFixture
      def test_error
        raise RuntimeError.new
      end
    end
  end
end