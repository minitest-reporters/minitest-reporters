require_relative "../../test_helper"
require "tmpdir"

module MinitestReportersTest
  class JUnitReporterTest < TestCase
    def test_replaces_special_characters_for_filenames_and_doesnt_crash
      fixtures_directory = File.expand_path('../../../fixtures', __FILE__)
      test_filename = File.join(fixtures_directory, 'junit_filename_bug_example_test.rb')
      output = `ruby #{test_filename} 2>&1`
      refute_match 'No such file or directory', output
    end

    def test_suite_time_is_wall_clock_not_sum_under_parallel
      fixtures_directory = File.expand_path('../../../fixtures', __FILE__)
      test_filename = File.join(fixtures_directory, 'parallel_test.rb')
      Dir.mktmpdir do |reports_dir|
        `REPORTS_DIR=#{reports_dir} ruby #{test_filename} 2>&1`

        report = File.read(File.join(reports_dir, 'TEST-ParallelSuite.xml'))
        suite_time = report[/<testsuite[^>]*\btime="([^"]+)"/, 1].to_f
        testcase_times = report.scan(/<testcase[^>]*\btime="([^"]+)"/).flatten.map(&:to_f)

        assert_equal 4, testcase_times.size
        sum = testcase_times.sum
        # Wall-clock envelope of a concurrent run is well under the sum of the
        # four ~0.4s tests; a summed time would be ~1.6s.
        assert_operator suite_time, :<, sum,
                        "suite time #{suite_time} should be less than summed durations #{sum}"
      end
    end

    if Gem::Version.new(Minitest::VERSION) >= Gem::Version.new('5.19.0')
      def test_outputs_screenshot_metadata
        test = Minitest::Test.new('test_fail')
        test.define_singleton_method(:test_fail) { assert false }
        test.metadata = { failure_screenshot_path: 'screenshot.png' }

        reporter = Minitest::Reporters::JUnitReporter.new('test/tmp')
        reporter.start
        reporter.record(test.run)
        reporter.report

        test_output = File.read('test/tmp/TEST-Minitest-Test.xml')
        assert_includes test_output, '<system-out>[[ATTACHMENT|screenshot.png]]</system-out>'
      end
    end
  end
end
