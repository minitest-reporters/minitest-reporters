require "test_helper"

module MiniTestReportersTest
  class ProgressReporterTest < TestCase
    # negated copy of assert_includes
    def assert_not_includes collection, obj, msg = nil
      msg = message(msg) { "Expected #{mu_pp(collection)} to not include #{mu_pp(obj)}" }
      assert_respond_to collection, :include?
      assert !collection.include?(obj), msg
    end

    def reporter(*args)
      Minitest::Reporters::ProgressReporter.new(*args)
    end

    def output(reporter)
      reporter.output.rewind
      reporter.output.read.gsub(/\e\[(\d+m|K)/,'') # decolorize
    end

    def setup
      out = StringIO.new
      @runner = stub(:output => out, :test_count => 1, :test_start_time => Time.now)
    end

    test "displays skip by default" do
      reporter = reporter(:runner => @runner)
      reporter.before_suites(:foo, :bar)
      reporter.skip(:foo, :bar, :baz)
      assert_includes output(reporter), "SKIP foo#bar (0.00s)"
    end

    test "hides skip when :hide_skip is given" do
      reporter = reporter(:runner => @runner, :detailed_skip => nil)
      reporter.before_suites(:foo, :bar)
      reporter.skip(:foo, :bar, :baz)
      assert_not_includes output(reporter), "SKIP foo#bar (0.00s)"
    end
  end
end
