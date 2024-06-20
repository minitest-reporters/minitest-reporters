module Minitest
  module Reporters
    class GithubReporter < BaseReporter
      def record(test)
        super
        return unless test.error? || test.skipped? || test.failure

        type = determine_type(test)
        output = create_output(test)
        message = test.failure.to_s
        if test.failure
          message << "\t"
          message << test.failure.backtrace[0]
        end

        puts "#{type} #{output.join(',')}::#{message}\n"
      end

      private

      def determine_type(test)
        if test.skipped?
          "::notice"
        else
          "::error"
        end
      end

      def create_output(test)
        loc = location(test.failure)
        if test.skipped?
          loc = test.source_location
        end
        {
          file: relative_path(loc[0]),
          line: loc[1],
          title: test.name,
        }.map { |k, v| "#{k}=#{escape_properties(v)}" }
      end

      def relative_path(path)
        Pathname.new(path).relative_path_from(Pathname.new(Dir.getwd))
      end

      def escape_properties(string)
        string.to_s.gsub("%", '%25')
              .gsub("\r", '%0D')
              .gsub("\n", '%0A')
              .gsub(":", '%3A')
              .gsub(",", '%2C')
      end

      def location(exception)
        last_before_assertion = ''
        exception.backtrace.reverse_each do |s|
          break if s =~ /in .(assert|refute|flunk|pass|fail|raise|must|wont)/

          last_before_assertion = s
        end

        out = last_before_assertion.sub(/:in .*$/, '')
        out.split(":")
      end
    end
  end
end
