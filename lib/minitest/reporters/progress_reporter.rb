require_relative '../reporter_base'
require 'ansi/code'
require 'powerbar'

module Minitest
  module Reporters

    class ProgressReporter < ReporterBase
      # Fuubar-like reporter with a progress bar.
      #
      # Originally based upon Jeff Kreefmeijer's Fuubar (MIT License) and paydro's
      # monkey-patch but modified to be minitest 5.0 compatible
      #
      # @see https://github.com/jeffkreeftmeijer/fuubar Fuubar
      # @see https://gist.github.com/356945 paydro's monkey-patch
      include ANSI::Code

      attr_accessor :io, :test_count, :assertion_count, :failures, :errors, :skips

      INFO_PADDING = 2

      def initialize(options = {})
        super(options)
        @detailed_skip = options.fetch(:detailed_skip, true)
        @progress = setup_progress_bar
      end

      def start
        self.start_time = Time.now

        @finished_count = 0
        show
      end

      def increment
        @finished_count += 1
        show
      end

      def show
        @progress.show({
          :msg => "#{@finished_count}/#{@total_tests}",
          :done => @finished_count,
          :total => @total_tests
          }, true)
      end

      def post_record(result)
        increment
      end

      def report
        @progress.close
        super
      end

      def pass(result)
      end

      def failure(result)
        wipe
        io.print(red { 'FAIL' })
        print_test_with_time(result)
        io.puts
        print_info(result.failure, false)
        io.puts

        self.color = RED
      end

      def error(result)
        wipe
        io.print(red { 'ERROR' })
        print_test_with_time(result)
        io.puts
        print_info(result.failure)
        io.puts

        self.color = RED
      end

      def skip(result)
        if @detailed_skip
          wipe
          io.print(yellow { 'SKIP' })
          print_test_with_time(result)
          io.puts
          io.puts
        end

        self.color = YELLOW unless color == RED
      end

      def passed?
        @passed
      end

      private

      def wipe
        @progress.wipe
      end

      def print_test_with_time(result)
        io.print(" %s#%s (%.2fs)%s" % [result.class, result.name, result.time, clr])
      end

      def print_info(result, name=true)
        io.print pad("#{result.exception.class}: ") if name
        result.message.each_line { |line| io.puts pad(line) }
      end

      def pad(str)
        ' ' * INFO_PADDING + str
      end

      def color
        @color ||= GREEN
      end

      def color=(color)
        @color = color
        @progress.scope.template.pre = "\e[1000D\e[?25l#{@color}"
      end

      def log(msg)
        io.flush
        io.puts("\n#{msg}")
        io.flush
        msg
      end

      def with_result(result)
        exception = result.failure
        msg = exception.nil? ? '' : "#{exception.class.name}: #{exception.message}"
        backtrace = exception.nil? ? '' : Minitest::filter_backtrace(exception.backtrace).join("\n")

        yield(msg, backtrace)
      end

      def setup_progress_bar
        progress = PowerBar.new(:msg => "")
        progress.settings.tty.finite.output = lambda { |s| print(s) }
        progress.settings.tty.finite.template.barchar = "="
        progress.settings.tty.finite.template.padchar = " "
        progress.settings.tty.finite.template.pre = "\e[1000D\e[?25l#{GREEN}"
        progress.settings.tty.finite.template.post = CLEAR
        progress
      end
    end
  end
end