module Minitest
  module Reporters
    module ANSI
      module Code

        def self.color?
          return false if ENV['MINITEST_REPORTERS_MONO']
          return true if ci_supports_color?
          color_terminal = ENV['TERM'].to_s.downcase.include?("color")
          $stdout.tty? || color_terminal
        end
        
        def self.ci_supports_color?
          # most CIs set this to `true`
          return false unless ENV['CI'] == 'true'

          # https://buildkite.com/docs/pipelines/environment-variables
          return true if ENV['BUILDKITE'] == 'true'
          # https://docs.github.com/en/enterprise-cloud@latest/actions/learn-github-actions/variables#default-environment-variables
          return true if ENV['GITHUB_ACTIONS'] == 'true'

          false
        end

        if color?
          require 'ansi/code'

          include ::ANSI::Code
          extend ::ANSI::Code
        else
          def black(s = nil)
            block_given? ? yield : s
          end

          %w[red green yellow blue magenta cyan white].each do |color|
            alias_method color, :black
          end

          extend self
        end
      end
    end
  end
end
