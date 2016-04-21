require 'builder'
require 'fileutils'
module Minitest
  module Reporters
    # A reporter for writing JUnit test reports
    # Intended for easy integration with CI servers - tested on JetBrains TeamCity
    #
    # Inspired by ci_reporter (see https://github.com/nicksieger/ci_reporter)
    # Also inspired by Marc Seeger's attempt at producing a JUnitReporter (see https://github.com/rb2k/minitest-reporters/commit/e13d95b5f884453a9c77f62bc5cba3fa1df30ef5)
    # Also inspired by minitest-ci (see https://github.com/bhenderson/minitest-ci)
    class JUnitReporter < BaseReporter
      def initialize(reports_dir = "test/reports", empty = true, options = {})
        super({})
        @reports_path = File.absolute_path(reports_dir)
        @single_file = options[:single_file]

        if empty
          puts "Emptying #{@reports_path}"
          FileUtils.mkdir_p(@reports_path)
          File.delete(*Dir.glob("#{@reports_path}/TEST-*.xml"))
        end
      end

      def report
        super

        puts "Writing XML reports to #{@reports_path}"
        suites = tests.group_by(&:class)

        if @single_file
          write_xml_file_for("minitest", tests.group_by(&:class).values.flatten)
        else
          suites.each do |suite, tests|
            write_xml_file_for(suite, tests)
          end
        end

      end

      private

      def write_xml_file_for(suite, tests)
        suite_result = analyze_suite(tests)

        xml = Builder::XmlMarkup.new(:indent => 2)
        xml.instruct!
        xml.testsuite(:name => suite, :skipped => suite_result[:skip_count], :failures => suite_result[:fail_count],
                      :errors => suite_result[:error_count], :tests => suite_result[:test_count],
                      :assertions => suite_result[:assertion_count], :time => suite_result[:time]) do
          tests.each do |test|
            xml.testcase(:name => test.name, :classname => suite, :assertions => test.assertions,
                         :time => test.time) do
              xml << xml_message_for(test) unless test.passed?
            end
          end
        end
        File.open(filename_for(suite), "w") { |file| file << xml.target! }
      end

      def xml_message_for(test)
        # This is a trick lifted from ci_reporter
        xml = Builder::XmlMarkup.new(:indent => 2, :margin => 2)

        def xml.trunc!(txt)
          txt.sub(/\n.*/m, '...')
        end

        e = test.failure

        if test.skipped?
          xml.skipped(:type => test.name)
        elsif test.error?
          xml.error(:type => test.name, :message => xml.trunc!(e.message)) do
            xml.text!(message_for(test))
          end
        elsif test.failure
          xml.failure(:type => test.name, :message => xml.trunc!(e.message)) do
            xml.text!(message_for(test))
          end
        end
      end

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

      def location(exception)
        last_before_assertion = ''
        exception.backtrace.reverse_each do |s|
          break if s =~ /in .(assert|refute|flunk|pass|fail|raise|must|wont)/
          last_before_assertion = s
        end
        last_before_assertion.sub(/:in .*$/, '')
      end

      def analyze_suite(tests)
        result = Hash.new(0)
        tests.each do |test|
          result[:"#{result(test)}_count"] += 1
          result[:assertion_count] += test.assertions
          result[:test_count] += 1
          result[:time] += test.time
        end
        result
      end

      def filename_for(suite)
        file_counter = 0
        suite_name = suite.to_s[0..240].gsub(/[^a-zA-Z0-9]+/, '-') # restrict max filename length, to be kind to filesystems
        filename = "TEST-#{suite_name}.xml"
        while File.exist?(File.join(@reports_path, filename)) # restrict number of tries, to avoid infinite loops
          file_counter += 1
          filename = "TEST-#{suite_name}-#{file_counter}.xml"
          puts "Too many duplicate files, overwriting earlier report #{filename}" and break if file_counter >= 99
        end
        File.join(@reports_path, filename)
      end
    end
  end
end
