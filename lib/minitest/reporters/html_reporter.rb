require 'builder'
require 'fileutils'
require 'erb'

module Minitest
  module Reporters
    class HtmlReporter < BaseReporter

      attr_reader :title

      def initialize(title = 'Test Results', reports_dir = "test/html_reports", empty = true)
        super({})
        @title = title
        @reports_path = File.absolute_path(reports_dir)

        if empty
          puts "Emptying #{@reports_path}"
          FileUtils.remove_dir(@reports_path) if File.exists?(@reports_path)
          FileUtils.mkdir_p(@reports_path)
        end
      end

      def report
        super

        puts "Writing HTML reports to #{@reports_path}"
        erb_file = "#{File.dirname(__FILE__)}/../templates/index.html.erb"
        html_file = @reports_path + "/index.html"
        erb_str = File.read(erb_file)
        renderer = ERB.new(erb_str)

        tests_by_suites = tests.group_by(&:class) # taken from the JUnit reporter

        suites = tests_by_suites.map do |suite, tests|
          suite_summary = summarize_suite(suite, tests)
          suite_summary[:tests] = tests.sort { |a, b| compare_tests(a, b) }
          suite_summary
        end

        suites.sort! { |a, b| compare_suites(a, b) }

        result = renderer.result(binding)
        File.open(html_file, 'w') do |f|
          f.write(result)
        end
      end

      def passes
        count - failures - errors - skips
      end

      def percent_passes
        100 - percent_skipps - percent_errors_failures # prevetns rounding errors
      end

      def percent_skipps
        (skips/count.to_f * 100).to_i
      end

      def percent_errors_failures
        ((errors+failures)/count.to_f * 100).to_i
      end

      def compare_suites_by_name(suite_a, suite_b)
        suite_a[:name] <=> suite_b[:name]
      end

      def compare_tests_by_name(test_a, test_b)
        friendly_name(test_a) <=> friendly_name(test_b)
      end

      def compare_suites(suite_a, suite_b)
        return compare_suites_by_name(suite_a, suite_b) if suite_a[:has_errors_or_failures] && suite_b[:has_errors_or_failures]
        return -1 if suite_a[:has_errors_or_failures] && !suite_b[:has_errors_or_failures]
        return 1 if !suite_a[:has_errors_or_failures] && suite_b[:has_errors_or_failures]

        return compare_suites_by_name(suite_a, suite_b) if suite_a[:has_skipps] && suite_b[:has_skipps]
        return -1 if suite_a[:has_skipps] && !suite_b[:has_skipps]
        return 1 if !suite_a[:has_skipps] && suite_b[:has_skipps]

        compare_suites_by_name(suite_a, suite_b)
      end

      def compare_tests(test_a, test_b)
        return compare_tests_by_name(test_a, test_b) if test_fail_or_error?(test_a) && test_fail_or_error?(test_b)

        return -1 if test_fail_or_error?(test_a) && !test_fail_or_error?(test_b)
        return 1 if !test_fail_or_error?(test_a) && test_fail_or_error?(test_b)

        return compare_tests_by_name(test_a, test_b) if test_a.skipped? && test_b.skipped?
        return -1 if test_a.skipped? && !test_b.skipped?
        return 1 if !test_a.skipped? && test_b.skipped?

        compare_tests_by_name(test_a, test_b)
      end

      def test_fail_or_error?(test)
        test.error? || test.failure
      end

      def friendly_name(test)
        groups = test.name.scan(/(test_\d+_)(.*)/i)
        return test.name if groups.empty?
        "it #{groups[0][1]}"
      end

      # based on analyze_suite from the JUnit reporter
      def summarize_suite(suite, tests)
        summary = Hash.new(0)
        summary[:name] = suite.to_s
        tests.each do |test|
          summary[:"#{result(test)}_count"] += 1
          summary[:assertion_count] += test.assertions
          summary[:test_count] += 1
          summary[:time] += test.time
        end
        summary[:has_errors_or_failures] = (summary[:fail_count] + summary[:error_count]) > 0
        summary[:has_skipps] = summary[:skip_count] > 0
        summary
      end

      # based on message_for(test) from the JUnit reporter
      def message_for(test)
        suite = test.class
        name = test.name
        e = test.failure

        if test.passed?
          nil
        elsif test.skipped?
          "Skipped:\n#{name}(#{suite}) [#{location(e)}]:\n#{e.message}\n"
        elsif test.failure
          "Failure:\n#{name}(#{suite}) [#{location(e)}]:\n#{e.message}\n"
        elsif test.error?
          "Error:\n#{name}(#{suite}):\n#{e.message}"
        end
      end

      # taken from the JUnit reporter
      def location(exception)
        last_before_assertion = ''
        exception.backtrace.reverse_each do |s|
          break if s =~ /in .(assert|refute|flunk|pass|fail|raise|must|wont)/
          last_before_assertion = s
        end
        last_before_assertion.sub(/:in .*$/, '')
      end

      def total_time_to_hms
        return ('%.2fs' % total_time) if total_time < 1

        hours = total_time / (60 * 60)
        minutes = ((total_time / 60) % 60).to_s.rjust(2,'0')
        seconds = (total_time % 60).to_s.rjust(2,'0')

        "#{ hours }h#{ minutes }m#{ seconds }s"
      end
    end
  end
end
