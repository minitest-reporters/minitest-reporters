module MiniTest
  class Reporter
    def runner
      MiniTest::Unit.runner
    end
    
    def output
      runner.output
    end
    
    def print(*args)
      runner.output.print(*args)
    end
    
    def puts(*args)
      runner.output.puts(*args)
    end
    
    def before_suites(suites); end
    def after_suites(suites); end
    def before_suite(suite); end
    def after_suite(suite); end
    def before_test(suite, test); end
    def pass(suite, test, runner); end
    def skip(suite, test, runner); end
    def failure(suite, test, runner); end
    def error(suite, test, runner); end
  end
end