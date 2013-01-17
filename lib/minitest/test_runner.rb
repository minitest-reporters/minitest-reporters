module MiniTest
  class TestRunner < Struct.new(:suite, :test, :assertions, :time, :exception)
    def result
      case exception
      when nil then :pass
      when Skip then :skip
      when Assertion then :failure
      else :error
      end
    end
  end
end
