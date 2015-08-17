module Minitest
  module Reporters
    class DelegateReporter
      def initialize(reporters, options = {})
        @reporters = reporters
        @options = options
        @all_reporters = nil
      end

      def start
        all_reporters.each(&:start)
      end

      def record(result)
        all_reporters.each do |reporter|
          reporter.record result
        end
      end

      def report
        all_reporters.each(&:report)
      end

      def passed?
        all_reporters.all?(&:passed?)
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

      def guard_reporter(reporters)
        guards = Array(reporters.detect { |r| r.class.name == "Guard::Minitest::Reporter" })
        return guards unless ENV['RM_INFO']

        warn 'RM_INFO is set thus guard reporter has been dropped' unless guards.empty?
        []
      end

      def all_reporters
        if @all_reporters.nil?
          if Minitest::Reporters.reporters
            @all_reporters = Minitest::Reporters.reporters + guard_reporter(@reporters)
            @all_reporters.each do |reporter|
              reporter.io = @options[:io]
              reporter.add_defaults(@options.merge(:total_count => total_count(@options))) if reporter.respond_to? :add_defaults
            end
          else
            @all_reporters = @reporters
          end
        end
        @all_reporters
      end
    end
  end

  class << self
    def plugin_minitest_reporter_init(options)
      reporter.reporters = [Minitest::Reporters::DelegateReporter.new(reporter.reporters, options)]
    end
  end
end
