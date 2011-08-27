module MiniTestReportersTest
  module Fixtures
    class FailureTestFixture < TestCaseFixture
      def test_failure
        flunk
      end
    end
  end
end