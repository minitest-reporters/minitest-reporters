module MiniTest
  module Reporter
    def runner
      reporter
    end

    def reporter
      self
    end

    def filter_backtrace(backtrace)
      MiniTest.filter_backtrace(backtrace)
    end

    def output
      io
    end

    def verbose?
      !!@verbose
    end

    def verbose=(verbose)
      @verbose = verbose
    end

    def print(*args)
      io.print(*args)
    end

    def puts(*args)
      io.puts(*args)
    end

    def before_suites(suites, type); end
    def after_suites(suites, type); end
    def before_suite(suite); end
    def after_suite(suite); end
    def before_test(suite, test); end
    def after_test(suite, test); end
    def pass(suite, test, test_runner); end
    def skip(suite, test, test_runner); end
    def failure(suite, test, test_runner); end
    def error(suite, test, test_runner); end
  end
end
