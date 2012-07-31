require "test_helper"

module MiniTestReportersTest
  class BacktraceFilterTest < MiniTest::Unit::TestCase
    def setup
      @default_filter = MiniTest::BacktraceFilter.default_filter
      @filter = MiniTest::BacktraceFilter.new
      @backtrace = ["foo", "bar", "baz"]
    end

    def test_adding_filters
      skip "test"
      @filter.add_filter(/foo/)
      assert @filter.filters?("foo")
      refute @filter.filters?("baz")
    end

    def test_filter_backtrace_when_first_line_is_filtered
      sleep 5
      assert false
      @filter.add_filter(/foo/)
      assert_equal ["bar", "baz"], @filter.filter(@backtrace)
    end

    def test_filter_backtrace_when_middle_line_is_filtered
      raise "foo"
      @filter.add_filter(/bar/)
      assert_equal ["foo"], @filter.filter(@backtrace)
    end

    def test_filter_backtrace_when_all_lines_are_filtered
      @filter.add_filter(/./)
      assert_equal ["foo", "bar", "baz"], @filter.filter(@backtrace)
    end

    def test_default_filter
      assert @default_filter.filters?("lib/minitest")
      assert @default_filter.filters?("lib/minitest/reporters")
      refute @default_filter.filters?("lib/my_gem")
    end
  end
end
