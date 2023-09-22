# Inspired by the rubocop formatter.
# https://github.com/rubocop/rubocop/blob/2f8239f61bd41fe672a4cd9d6f24e334eba7854a/lib/rubocop/formatter/git_hub_actions_formatter.rb

module Minitest
  module Reporters
    # Simple reporter designed for Github Actions
    class GithubActionsReporter < BaseReporter
      ESCAPE_MAP = { '%' => '%25', "\n" => '%0A', "\r" => '%0D' }.freeze

      def start
        super

        print_run_options
      end

      def record(test)
        super

        print(message_for(test))
      end

      def message_for(test)
        if test.passed? || test.skipped?
          nil
        elsif test.failure
          to_annotation(test, "Failure")
        elsif test.error?
          to_annotation(test, "Error")
        end
      end

      private

      def to_annotation(test, failure_type)
        message = "#{failure_type}: #{test.name}\n\n#{test.failure.message}"
        line_number = location(test.failure).split(":").last

        "\n::error file=%<file>s,line=%<line>d::%<message>s" % {
          file: get_relative_path(test),
          line: line_number,
          message: github_escape(message),
        }
      end

      def github_escape(string)
        string.gsub(Regexp.union(ESCAPE_MAP.keys), ESCAPE_MAP)
      end
    end
  end
end
