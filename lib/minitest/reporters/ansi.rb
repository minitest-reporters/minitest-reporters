module Minitest
  module Reporters
    module ANSI
      module Code
        if ($stdout.tty?)
          require 'ansi/code'

          include ::ANSI::Code
          extend ::ANSI::Code
        else
          def black(s = nil)
            block_given? ? yield : s
          end

          %w[ red green yellow blue magenta cyan white ].each do |color|
            alias_method color, :black
          end

          extend self
        end
      end
    end
  end
end
