module Minitest
  class << self
    def plugin_minitest_reporter_init(options)
      if defined?(Minitest::Reporters) && Minitest::Reporters.reporters
        reporter.reporters = Minitest::Reporters.reporters + guard_reporter
        reporter.reporters.each do |reporter|
          reporter.io = options[:io]
          reporter.add_defaults(options.merge(:total_count => total_count(options)))
        end
      end
    end

    private

    # stolen from minitest self.run
    def total_count(options)
      filter = options[:filter] || '/./'
      filter = Regexp.new $1 if filter =~ /\/(.*)\//

      Minitest::Runnable.runnables.map(&:runnable_methods).flatten.find_all { |m|
        filter === m || filter === "#{self}##{m}"
      }.size
    end

    def guard_reporter
      Array(reporter.reporters.detect { |r| r.class.name == "Guard::Minitest::Reporter" })
    end
  end
end
