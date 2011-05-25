module MiniTestReporterTest
  module Fixtures
    class SkipTestFixture < TestCaseFixture
      def test_skip
        skip
      end
    end
  end
end