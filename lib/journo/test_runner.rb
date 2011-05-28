module Journo
  # Runner for individual MiniTest tests.
  # 
  # You *should not* create instances of this class directly. Instances of
  # {SuiteRunner} will create these and send them to the reporters.
  # 
  # Based upon Ryan Davis of Seattle.rb's MiniTest (MIT License).
  # 
  # @see https://github.com/seattlerb/minitest MiniTest
  class TestRunner
    attr_reader :suite, :test, :assertions, :result, :exception
    
    def initialize(suite, test)
      @suite = suite
      @test = test
      @assertions = 0
    end
    
    def run
      suite_instance = suite.new(test)
      @result, @exception = fix_result(suite_instance.run(self))
      @assertions = suite_instance._assertions
    end
    
    def puke(suite, test, exception)
      case exception
      when MiniTest::Skip then [:skip, exception]
      when MiniTest::Assertion then [:failure, exception]
      else [:error, exception]
      end
    end
    
    private
    
    def fix_result(result)
      result == '.' ? [:pass, nil] : result
    end
  end
end