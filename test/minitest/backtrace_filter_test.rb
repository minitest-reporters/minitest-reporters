require "test_helper"

module MiniTestReportersTest
  class BacktraceFilterTest < TestCase
    def setup
      @default_filter = MiniTest::BacktraceFilter.default_filter
      @filter = MiniTest::BacktraceFilter.new
      @backtrace = ["foo", "bar", "baz"]
    end

    test "adding filters" do
      @filter.add_filter(/foo/)
      assert @filter.filters?("foo")
      refute @filter.filters?("baz")
    end

    test "filter backtrace when first line is filtered" do
      @filter.add_filter(/foo/)
      assert_equal ["bar", "baz"], @filter.filter(@backtrace)
    end

    test "filter backtrace when middle line is filtered" do
      @filter.add_filter(/bar/)
      assert_equal ["foo"], @filter.filter(@backtrace)
    end

    test "filter backtrace when all lines are filtered" do
      @filter.add_filter(/./)
      assert_equal ["foo", "bar", "baz"], @filter.filter(@backtrace)
    end

    test "default filter" do
      assert @default_filter.filters?("lib/minitest")
      assert @default_filter.filters?("lib/minitest/reporters")
      refute @default_filter.filters?("lib/my_gem")
    end
  end
end
