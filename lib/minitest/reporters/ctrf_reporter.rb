# frozen_string_literal: true

require 'json'
require 'fileutils'

module Minitest
  module Reporters
    # Writes one CTRF document for the recorded run without removing other reports.
    class CTRFReporter < BaseReporter
      DEFAULT_REPORTS_DIR = "test/reports"
      DEFAULT_OUTPUT_FILENAME = "ctrf-report.json"

      attr_reader :reports_path

      def initialize(reports_dir = DEFAULT_REPORTS_DIR, options = {})
        super(options)
        @reports_path = File.absolute_path(ENV.fetch("MINITEST_REPORTERS_REPORTS_DIR", reports_dir))
        @output_filename = options[:output_filename] || DEFAULT_OUTPUT_FILENAME
      end

      def start
        super
        @start = (Time.now.to_f * 1000).to_i
      end

      def report
        super
        stop = (Time.now.to_f * 1000).to_i
        json = JSON.pretty_generate(document(stop)) + "\n"
        destination = File.join(reports_path, @output_filename)
        FileUtils.mkdir_p(File.dirname(destination))
        File.open(destination, "w:UTF-8") { |file| file.write(json) }
      end

      private

      def document(stop)
        summary = {
          :tests => tests.length, :passed => 0, :failed => 0, :skipped => 0,
          :pending => 0, :other => 0, :start => @start, :stop => stop
        }
        rows = tests.map do |test|
          row = test_row(test)
          summary[row[:status].to_sym] += 1
          row
        end

        {
          :reportFormat => "CTRF",
          :specVersion => "0.0.0",
          :generatedBy => "minitest-reporters",
          :results => {
            :tool => { :name => "minitest", :version => Minitest::VERSION },
            :summary => summary,
            :tests => rows
          }
        }
      end

      def test_row(test)
        status = case result(test)
                 when :pass then "passed"
                 when :skip then "skipped"
                 else "failed"
                 end
        row = { :name => test.name, :status => status, :duration => (test.time * 1000).round }
        suite = test_class(test).name.to_s
        row[:suite] = [suite] unless suite.empty?

        unless status == "passed"
          row[:message] = test.failures.map(&:message).join("\n")
          trace = test.failures.flat_map { |failure| filter_backtrace(failure.backtrace || []) }
          row[:trace] = trace.join("\n") unless trace.empty?
        end
        row
      end
    end
  end
end
