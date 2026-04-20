require_relative "../../test_helper"

module MinitestReportersTest
  class SpecdocReporterTest < Minitest::Test
    def setup
      @reporter = Minitest::Reporters::SpecdocReporter.new
      @test = Minitest::Test.new("")
      @test.time = 0
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

    def test_specdoc_reporter_with_option_show_order_after_and_test_syntax_name_should_remove_test__prefix
      reporter = Minitest::Reporters::SpecdocReporter.new(:show_order => :after)
      @test.name = "test_should_return_the_correct_path"
      @test.time = 0.1
      assert_output(/^  should_return_the_correct_path \s* PASS \(\d\.\d\ds\)\n$/) do
        reporter.io = $stdout
        reporter.record(@test)
      end
    end

    def test_specdoc_reporter_with_option_show_order_after_and_spec_syntax_test_name_should_remove_test_000X
      reporter = Minitest::Reporters::SpecdocReporter.new
      @test.name = "test_0001_should return the correct path"
      @test.time = 0.1
      assert_output(/^  should return the correct path \s* PASS \(\d\.\d\ds\)\n$/) do
        reporter.io = $stdout
        reporter.record(@test)
      end
    end

    def test_specdoc_reporter_with_option_show_order_after_and_shoulda_syntax_test_name_should_remove_test__colon
      reporter = Minitest::Reporters::SpecdocReporter.new
      @test.name = "test_: Should return the correct path"
      @test.time = 0.1
      assert_output(/^  Should return the correct path \s* PASS \(\d\.\d\ds\)\n$/) do
        reporter.io = $stdout
        reporter.record(@test)
      end
    end

    def test_specdoc_reporter_with_option_show_order_after_and_show_time_false_should_exclude_timer
      reporter = Minitest::Reporters::SpecdocReporter.new(:show_time => false)
      @test.name = "test_should_return_the_correct_path"
      @test.time = 0.1
      assert_output(/^  should_return_the_correct_path \s* PASS\n$/) do
        reporter.io = $stdout
        reporter.record(@test)
      end
    end

    def test_specdoc_reporter_with_option_show_order_after_and_show_status_false_should_exclude_status
      reporter = Minitest::Reporters::SpecdocReporter.new(:show_status => false)
      @test.name = "test_should_return_the_correct_path"
      @test.time = 0.1
      assert_output(/^  should_return_the_correct_path \s* \(\d\.\d\ds\)\n$/) do
        reporter.io = $stdout
        reporter.record(@test)
      end
    end

    def test_specdoc_reporter_with_option_show_order_before_and_test_syntax_name_should_remove_test__prefix
      reporter = Minitest::Reporters::SpecdocReporter.new(:show_order => :before)
      @test.name = "test_should_return_the_correct_path"
      @test.time = 0.1
      assert_output(/^ PASS  should_return_the_correct_path  -  \(\d\.\d\ds\)\n$/) do
        reporter.io = $stdout
        reporter.record(@test)
      end
    end

    def test_specdoc_reporter_with_option_show_order_before_and_spec_syntax_name_should_remove_test_000X_from_test_name
      reporter = Minitest::Reporters::SpecdocReporter.new(:show_order => :before)
      @test.name = "test_0099_should return the correct path"
      @test.time = 0.1
      assert_output(/^ PASS  should return the correct path  -  \(\d\.\d\ds\)\n$/) do
        reporter.io = $stdout
        reporter.record(@test)
      end
    end

    def test_specdoc_reporter_with_option_show_order_before_and_shoulda_syntax_name
      reporter = Minitest::Reporters::SpecdocReporter.new(:show_order => :before)
      @test.name = "test_: Should return the correct path"
      @test.time = 0.1
      assert_output(/^ PASS  Should return the correct path  -  \(\d\.\d\ds\)\n$/) do
        reporter.io = $stdout
        reporter.record(@test)
      end
    end

    def test_specdoc_reporter_with_option_show_order_before_and_show_time_false_should_exclude_timer
      reporter = Minitest::Reporters::SpecdocReporter.new(:show_order => :before, :show_time => false)
      @test.name = "test_should_return_the_correct_path"
      @test.time = 0.1
      assert_output(/^ PASS  should_return_the_correct_path\n$/) do
        reporter.io = $stdout
        reporter.record(@test)
      end
    end

    def test_specdoc_reporter_with_option_show_order_before_and_show_status_false_should_exclude_status
      reporter = Minitest::Reporters::SpecdocReporter.new(:show_order => :before, :show_status => false)
      @test.name = "test_should_return_the_correct_path"
      @test.time = 0.1
      assert_output(/^  should_return_the_correct_path  -  \(\d\.\d\ds\)\n$/) do
        reporter.io = $stdout
        reporter.record(@test)
      end
    end
  end
end
