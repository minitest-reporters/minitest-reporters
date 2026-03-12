require_relative "../../test_helper"

module MinitestReportersTest
  class NilBacktraceTest < Minitest::Test
    # Exceptions can have nil backtraces in certain environments (e.g.,
    # when raised during Zeitwerk eager loading retries, or when
    # constructed manually without being raised). All reporters that
    # walk exception.backtrace should handle nil gracefully.

    FakeException = Struct.new(:message, :backtrace, :exception, :class) do
      def is_a?(klass)
        klass == self.class
      end
    end

    def build_exception(message: "something went wrong", backtrace: nil)
      exc = FakeException.new(message, backtrace)
      exc.exception = exc
      exc.class = RuntimeError
      exc
    end

    # -- DefaultReporter#location --

    def test_default_reporter_location_with_nil_backtrace
      reporter = Minitest::Reporters::DefaultReporter.new
      exception = build_exception

      result = reporter.send(:location, exception)
      assert_equal "", result
    end

    def test_default_reporter_location_with_normal_backtrace
      reporter = Minitest::Reporters::DefaultReporter.new
      # Backtrace is ordered innermost-first (like Ruby's default).
      # The location method walks from the outermost frame inward,
      # stopping just before the first assertion frame.
      exception = build_exception(backtrace: [
        "/path/to/minitest.rb:20:in `assert_equal'",
        "/path/to/test_file.rb:10:in `test_something'",
      ])

      result = reporter.send(:location, exception)
      assert_equal "/path/to/test_file.rb:10", result
    end

    # -- JUnitReporter#location --

    def test_junit_reporter_location_with_nil_backtrace
      reporter = Minitest::Reporters::JUnitReporter.new("report", false)
      exception = build_exception

      result = reporter.send(:location, exception)
      assert_equal "", result
    end

    # -- HtmlReporter#location --

    def test_html_reporter_location_with_nil_backtrace
      reporter = Minitest::Reporters::HtmlReporter.new
      exception = build_exception

      result = reporter.send(:location, exception)
      assert_equal "", result
    end

    # -- BaseReporter#print_info --

    def test_base_reporter_print_info_with_nil_backtrace
      reporter = Minitest::Reporters::SpecReporter.new
      reporter.io = StringIO.new
      exception = build_exception

      # Should not raise NoMethodError
      assert_silent_or_output(reporter) do
        reporter.send(:print_info, exception, false)
      end
    end

    private

    def assert_silent_or_output(reporter)
      yield
    rescue NoMethodError => e
      flunk "Expected no NoMethodError for nil backtrace, but got: #{e.message}"
    end
  end
end
