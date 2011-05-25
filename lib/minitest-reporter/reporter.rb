module MiniTest
  class Reporter
    def runner
      MiniTest::Unit.runner
    end
    
    def output
      runner.output
    end
    
    def verbose?
      runner.verbose
    end
    
    def print(*args)
      runner.output.print(*args)
    end
    
    def puts(*args)
      runner.output.puts(*args)
    end
    
    def before_suites(suites, type); end
    def after_suites(suites, type); end
    def before_suite(suite); end
    def after_suite(suite); end
    def before_test(suite, test); end
    def pass(suite, test, test_runner); end
    def skip(suite, test, test_runner); end
    def failure(suite, test, test_runner); end
    def error(suite, test, test_runner); end
  end
end