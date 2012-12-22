require 'ansi/code'

module MiniTest
  module Reporters
    # A reporter similar to the default reporter except when tests
    # fail or have errors show the full description during the test
    # run instead of at the end
    class FastFailReporter
      include Reporter
      include ANSI::Code

      TEST_PADDING = 2
      TEST_SIZE = 63
      MARK_SIZE = 5
      INFO_PADDING = 8

      def initialize(options = {})
        @detailed_skip = options.fetch(:detailed_skip, true)
        @slow_count = options.fetch(:slow_count, 0)
        @slow_suite_count = options.fetch(:slow_suite_count, 0)
        @test_times = []
        @suite_times = []
        @color = options.fetch(:color) do
          output.tty? && (
            ENV["TERM"] == "screen" ||
            ENV["TERM"] =~ /term(?:-(?:256)?color)?\z/ ||
            ENV["EMACS"] == "t"
          )
        end
      end

      def before_suites(suites, type)
        puts
        puts "# Running #{type}s:"
        puts
      end

      def before_test(suite, test)
        @test_name = "#{suite}##{test}"
        print "#{@test_name} = " if verbose?
      end

      def pass(suite, test, test_runner)
        after_test(green('.'))
      end

      def skip(suite, test, test_runner)
        after_test(yellow('S'))
      end

      def failure(suite, test, test_runner)
        after_test(red('F'))

        puts
        puts suite.name
        print pad_test(test)

        print(red { pad_mark('FAIL') })
        print_time(test)
        puts
        print_info(test_runner.exception)
        puts
      end

      def error(suite, test, test_runner)
        after_test(red('E'))

        puts
        puts suite.name
        print pad_test(test)

        print(red { pad_mark('ERROR') })
        print_time(test)
        puts
        print_info(test_runner.exception)
        puts
      end

      def after_suite(suite)
        time = Time.now - runner.suite_start_time
        @suite_times << [suite.name, time]
      end

      def after_suites(suites, type)
        time = Time.now - runner.suites_start_time
        status_line = "Finished %ss in %.6fs, %.4f tests/s, %.4f assertions/s." %
          [type, time, runner.test_count / time, runner.assertion_count / time]

        puts
        puts
        puts colored_for(suite_result, status_line)

        if @slow_count > 0
          slow_tests = @test_times.sort_by { |x| x[1] }.reverse.take(@slow_count)

          puts
          puts "Slowest tests:"
          puts

          slow_tests.each do |slow_test|
            puts "%.6fs %s" % [slow_test[1], slow_test[0]]
          end
        end

        if @slow_suite_count > 0
          slow_suites = @suite_times.sort_by { |x| x[1] }.reverse.take(@slow_suite_count)

          puts
          puts "Slowest test classes:"
          puts

          slow_suites.each do |slow_suite|
            puts "%.6fs %s" % [slow_suite[1], slow_suite[0]]
          end
        end

        puts
        print colored_for(suite_result, result_line)
      end

      private

      def colored_for(result, string)
        case result
        when :failure, :error; red(string)
        when :skip; yellow(string)
        else green(string)
        end
      end

      def suite_result
        case
        when runner.failures > 0; :failure
        when runner.errors > 0; :error
        when runner.skips > 0; :skip
        else :pass
        end
      end

      def after_test(result)
        time = Time.now - runner.test_start_time
        @test_times << [@test_name, time]

        print '%.2f s = ' % time if verbose?
        print result
        puts if verbose?
      end

      def location(exception)
        last_before_assertion = ''

        exception.backtrace.reverse_each do |s|
          break if s =~ /in .(assert|refute|flunk|pass|fail|raise|must|wont)/
          last_before_assertion = s
        end

        last_before_assertion.sub(/:in .*$/, '')
      end

      def message_for(test_runner)
        suite = test_runner.suite
        test = test_runner.test
        e = test_runner.exception

        case test_runner.result
        when :pass then nil
        when :skip
          if @detailed_skip
            "Skipped:\n#{test}(#{suite}) [#{location(e)}]:\n#{e.message}\n"
          end
        when :failure then "Failure:\n#{test}(#{suite}) [#{location(e)}]:\n#{e.message}\n"
        when :error
          bt = filter_backtrace(test_runner.exception.backtrace).join "\n    "
          "Error:\n#{test}(#{suite}):\n#{e.class}: #{e.message}\n    #{bt}\n"
        end
      end

      def result_line
        '%d tests, %d assertions, %d failures, %d errors, %d skips' %
          [runner.test_count, runner.assertion_count, runner.failures, runner.errors, runner.skips]
      end

      def print_time(test)
        total_time = Time.now - runner.test_start_time
        print(" (%.2fs)" % total_time)
      end

      def print_info(e)
        e.message.each_line { |line| puts pad(line, INFO_PADDING) }

        trace = filter_backtrace(e.backtrace)
        trace.each { |line| puts pad(line, INFO_PADDING) }
      end

      def pad(str, size)
        ' ' * size + str
      end

      def pad_mark(str)
        "%#{MARK_SIZE}s" % str
      end

      def pad_test(str)
        pad("%-#{TEST_SIZE}s" % str, TEST_PADDING)
      end
    end
  end
end
