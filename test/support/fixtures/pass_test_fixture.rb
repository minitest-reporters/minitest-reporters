module MiniTestReportersTest
  module Fixtures
    class PassTestFixture < TestCaseFixture
      def test_pass
        assert true
      end
      
      def test_foo
        assert true
        assert true
      end
    end
  end
end