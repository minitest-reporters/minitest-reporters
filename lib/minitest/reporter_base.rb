module Minitest
  class ReporterBase < Minitest::Reporter
    attr_accessor :io, :test_count, :assertion_count, :failures, :errors, :skips, :total_tests

    def initialize(options = {})
      super(options.delete(:io) || $stdout, options)
      @total_tests = options[:total_tests]
      @passed = true
    end

    def record(result)
      pre_record(result)

      if result.passed?
        pass(result)
      elsif result.skipped?
        skip(result)
      elsif result.error?
        error(result)
      elsif result.failure
        failure(result)
      end

      post_record(result)
    end

    def passed?
      @passed
    end

    def verbose?
      @verbose || false
    end

    def print(*args)
      io.print(*args)
    end

    def puts(*args)
      io.puts(*args)
    end

    def pre_record(result); end
    def post_record(result); end

    def pass(result);end

    def skip(result)
      raise NotImplementedError "To be implemented by subclass"
    end

    def error(result)
      raise NotImplementedError "To be implemented by subclass"
    end

    def failure(result)
      raise NotImplementedError "To be implemented by subclass"
    end
  end
end