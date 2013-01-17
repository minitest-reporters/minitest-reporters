module MiniTest
  class TestRecorder
    def initialize
      @records = {}
    end

    def [](suite, test)
      name = [suite, test]
      @records[name]
    end

    def record(runner)
      name = [runner.suite, runner.test]
      @records[name] ||= []
      @records[name] << runner
    end

    def assertion_count
      @records.inject(0) { |acc, r| acc + r.last.last.assertions }
    end
  end
end
