module Minitest
  module Reporters
    class Suite
      attr_reader :name
      def initialize(name)
        @name = name
      end

      def ==(other)
        name == other.name
      end

      def eql?(other)
        self == other
      end

      def hash
        name.hash
      end

      def to_s
        name.to_s
      end
    end
    class BaseReporter < Minitest::StatisticsReporter
      attr_accessor :tests

      def initialize(options = {})
        super($stdout, options)
        self.tests = []
      end

      def add_defaults(defaults)
        self.options = defaults.merge(options)
      end

      # called by our own before hooks
      def before_test(test)
        last_test = test_class(tests.last)

        suite_changed = last_test.nil? || last_test.name != test.class.name

        return unless suite_changed

        after_suite(last_test) if last_test
        before_suite(test_class(test))
      end

      def record(test)
        super
        tests << test
      end

      # called by our own after hooks
      def after_test(_test); end

      def report
        super
        if last_suite = test_class(tests.last)
          after_suite(last_suite)
        end
      end

      def print_finished
        puts('Finished in %s' % format_duration(total_time))
        print('%d tests, %d assertions, ' % [count, assertions])
        color = failures.zero? && errors.zero? ? :green : :red
        print(send(color, '%d failures, %d errors, ') % [failures, errors])
        print(yellow '%d skips' % skips)
        puts
      end

      def format_duration(duration, sigfig: 3)
        return('[negative duration]') if duration < 0 # duration should be positive, but nonmonotonic clock is possible

        seconds = format_sigfig(duration, sigfig: sigfig, mod: 60)

        if duration > 60 * 60
          "%ih %im %ss" % [duration / 60 / 60, duration / 60 % 60, seconds]
        elsif duration > 60
          "%im %ss" % [duration / 60, seconds]
        else
          "%ss" % seconds
        end
      end

      # @param sigfig [Integer] minimum number of digits to include (not including leading 0s if duration < 1s)
      # @param mod the number of digits after the decimal point is computed from `n`,
      #   but the formatted number returned will be `n` modulo this
      def format_sigfig(n, sigfig: 3, mod: nil)
        lg = n == 0 ? 0 : Math.log10(n.abs).floor
        n = n % mod if mod
        if lg - sigfig + 1 < 0
          "%.#{sigfig - lg - 1}f" % n
        else
          "%i" % n
        end
      end

      protected

      def after_suite(test); end

      def before_suite(test); end

      def result(test)
        if test.error?
          :error
        elsif test.skipped?
          :skip
        elsif test.failure
          :fail
        else
          :pass
        end
      end

      def test_class(result)
        # Minitest broke API between 5.10 and 5.11 this gets around Result object
        if result.nil?
          nil
        elsif result.respond_to? :klass
          Suite.new(result.klass)
        else
          Suite.new(result.class.name)
        end
      end

      def print_colored_status(test)
        if test.passed?
          print(green { pad_mark(result(test).to_s.upcase) })
        elsif test.skipped?
          print(yellow { pad_mark(result(test).to_s.upcase) })
        else
          print(red { pad_mark(result(test).to_s.upcase) })
        end
      end

      def total_time
        super || Minitest::Reporters.clock_time - start_time
      end

      def total_count
        options[:total_count]
      end

      def filter_backtrace(backtrace)
        Minitest.filter_backtrace(backtrace)
      end

      def puts(*args)
        io.puts(*args)
      end

      def print(*args)
        io.print(*args)
      end

      def print_info(e, name = true)
        print "#{e.exception.class}: " if name
        e.message.each_line { |line| print_with_info_padding(line) }

        # When e is a Minitest::UnexpectedError, the filtered backtrace is already part of the message printed out
        # by the previous line. In that case, and that case only, skip the backtrace output.
        return if e.is_a?(Minitest::UnexpectedError)

        trace = filter_backtrace(e.backtrace)
        trace.each { |line| print_with_info_padding(line) }
      end
    end
  end
end
