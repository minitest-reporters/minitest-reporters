module MiniTestReporterTest
  module Fixtures
    class SuiteCallbackTestFixture < TestCaseFixture
      def self.startup; end
      def self.shutdown; end
      def test_foo; end
    end
  end
end