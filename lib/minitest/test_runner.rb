module MiniTest
  TestRunner = Struct.new(:suite, :test, :assertions, :time, :result, :exception)
end
