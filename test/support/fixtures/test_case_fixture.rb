module JournoTest
  module Fixtures
    class TestCaseFixture
      attr_writer :_assertions
      
      def self.test_methods
        public_instance_methods(true).grep(/^test/)
      end
      
      def initialize(test)
        @test = test
      end
      
      def run(runner)
        send(@test)
        '.'
      rescue MiniTest::Assertion, RuntimeError => e
        runner.puke(self, @test, e)
      end
      
      def skip
        raise MiniTest::Skip.new
      end
      
      def flunk
        raise MiniTest::Assertion.new
      end
      
      def assert(value)
        self._assertions += 1
      end
      
      def _assertions
        @_assertions ||= 0
      end
    end
  end
end