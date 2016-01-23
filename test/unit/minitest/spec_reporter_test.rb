require_relative "../../test_helper"

module MinitestReportersTest
  class SpecReporterTest < Minitest::Test
    def setup
      @reporter = Minitest::Reporters::SpecReporter.new
      @test = Minitest::Test.new("")
      @test.time = 0
    end

    def test_removes_underscore_in_name_if_shoulda
      @test.name = "test_: Should foo"
      assert_output(/test:/) do
        @reporter.io = $stdout
        @reporter.record(@test)
      end
    end

    def test_wont_modify_name_if_not_shoulda
      @test.name = "test_foo"
      assert_output(/test_foo/) do
        @reporter.io = $stdout
        @reporter.record(@test)
      end
    end

    def test_responds_to_test_name_after_record
      test_name = 'test_: Should foo'
      the_test_class = Class.new(Minitest::Test) do
        define_method test_name do
          assert(false)
        end
      end
      the_test = the_test_class.new('')
      the_test.name = test_name
      @reporter.io = StringIO.new
      @reporter.record(the_test)
      assert_respond_to the_test, the_test.name
    end

    def test_spec_reporter_with_option_show_order_after
      reporter = Minitest::Reporters::SpecReporter.new(show_order: :after)
      @test.name = "test_should_work_with_show_order_after"
      @test.time = 0.1
      assert_output(/^  test_should_work_with_show_order_after \s* PASS \(\d\.\d\ds\)\n$/) do
        reporter.io = $stdout
        reporter.record(@test)
      end
    end

    def test_spec_reporter_with_option_show_order_before
      reporter = Minitest::Reporters::SpecReporter.new(show_order: :before)
      @test.name = "test_should_work_with_show_order_before"
      @test.time = 0.1
      assert_output(/^ PASS  should_work_with_show_order_before  -  \(\d\.\d\ds\)\n$/) do
        reporter.io = $stdout
        reporter.record(@test)
      end
    end

    def test_spec_reporter_with_option_show_order_before_and_show_time_false
      reporter = Minitest::Reporters::SpecReporter.new(show_order: :before, show_time: false)
      @test.name = "test_should_work_with_show_order_before_and_show_time_false"
      @test.time = 0.1
      assert_output(/^ PASS  should_work_with_show_order_before_and_show_time_false\n$/) do
        reporter.io = $stdout
        reporter.record(@test)
      end
    end

    def test_spec_reporter_with_option_show_order_before_and_show_status_false
      reporter = Minitest::Reporters::SpecReporter.new(show_order: :before, show_status: false)
      @test.name = "test_should_work_with_show_status_false"
      @test.time = 0.1
      assert_output(/^  should_work_with_show_status_false  -  \(\d\.\d\ds\)\n$/) do
        reporter.io = $stdout
        reporter.record(@test)
      end
    end
  end
end
