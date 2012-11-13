# Test results reporter for RubyMine IDE (http://www.jetbrains.com/ruby/) and
# TeamCity(http://www.jetbrains.com/teamcity/) Continuous Integration Server

require 'ansi/code'
begin
  require 'teamcity/runner_common'
  require 'teamcity/utils/service_message_factory'
  require 'teamcity/utils/runner_utils'
  require 'teamcity/utils/url_formatter'
rescue LoadError
  MiniTest::Unit.runner.output.puts("====================================================================================================\n")
  MiniTest::Unit.runner.output.puts("RubyMine reporter works only if it test was launched using RubyMine IDE or TeamCity CI server !!!\n")
  MiniTest::Unit.runner.output.puts("====================================================================================================\n")
  MiniTest::Unit.runner.output.puts("Using default results reporter...\n")

  require "minitest/reporters/default_reporter"

  # delegate to default reporter
  module MiniTest
    module Reporters
      class RubyMineReporter < DefaultReporter
      end
    end
  end
else
  module MiniTest
    module Reporters
      class RubyMineReporter
        include Reporter
        include ANSI::Code

        include ::Rake::TeamCity::RunnerCommon
        include ::Rake::TeamCity::RunnerUtils
        include ::Rake::TeamCity::Utils::UrlFormatter

        def runner
          MiniTest::Unit.runner
        end

        def output
          runner.output
        end

        def verbose?
          runner.verbose
        end

        def print(*args)
          runner.output.print(*args)
        end

        def puts(*args)
          runner.output.puts(*args)
        end

        def before_suites(suites, type)
          puts 'Started'
          puts

          # Setup test runner's MessageFactory
          set_message_factory(Rake::TeamCity::MessageFactory)
          log_test_reporter_attached()

          # Report tests count:
          test_count = runner.test_count
          if ::Rake::TeamCity.is_in_idea_mode
            log(@message_factory.create_tests_count(test_count))
          elsif ::Rake::TeamCity.is_in_buildserver_mode
            log(@message_factory.create_progress_message("Starting.. (#{test_count} tests)"))
          end

        end

        def after_suites(suites, type)
          total_time = Time.now - runner.suites_start_time

          puts('Finished in %.5fs' % total_time)
          print('%d tests, %d assertions, ' % [runner.test_count, runner.assertion_count])
          print(red { '%d failures, %d errors, ' } % [runner.failures, runner.errors])
          print(yellow { '%d skips' } % runner.skips)
          puts
        end

        def before_suite(suite)
          fqn = suite.name
          log(@message_factory.create_suite_started(suite.name, location_from_ruby_qualified_name(fqn)))
        end

        def after_suite(suite)
          log(@message_factory.create_suite_finished(suite.name))
        end

        def before_test(suite, test)
          fqn = "#{suite.name}.#{test.to_s}"
          log(@message_factory.create_test_started(test, minitest_test_location(fqn)))
        end

        def pass(suite, test, test_runner)
          test_finished(test, test_runner)
        end

        def skip(suite, test, test_runner)
          test_finished(test, test_runner) do |exception_msg, backtrace|
            log(@message_factory.create_test_ignored(test, exception_msg, backtrace))
          end
        end

        def failure(suite, test, test_runner)
          test_finished(test, test_runner) do |exception_msg, backtrace|
            log(@message_factory.create_test_failed(test, exception_msg, backtrace))
          end
        end

        def error(suite, test, test_runner)
          test_finished(test, test_runner) do |exception_msg, backtrace|
            log(@message_factory.create_test_error(test, exception_msg, backtrace))
          end
        end

        #########
        def log(msg)
          output.flush
          output.puts("\n#{msg}")
          output.flush

          # returns:
          msg
        end

        def minitest_test_location(fqn)
          return nil if (fqn.nil?)
          "ruby_minitest_qn://#{fqn}"
        end

        def test_finished(test, test_runner)
          duration_ms = get_current_time_in_ms() - get_time_in_ms(runner.test_start_time)

          begin
            if block_given?
              exception = test_runner.exception
              msg = exception.nil? ? "" : "#{exception.class.name}: #{exception.message}"
              backtrace = exception.nil? ? "" : filter_backtrace(exception.backtrace).join("\n")

              yield(msg, backtrace)
            end
          ensure
            log(@message_factory.create_test_finished(test, duration_ms.nil? ? 0 : duration_ms))
          end
        end
      end
    end
  end
end

