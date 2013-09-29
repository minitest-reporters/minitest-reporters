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
      class RubyMineReporter < BaseReporter
        include ANSI::Code

        include ::Rake::TeamCity::RunnerCommon
        include ::Rake::TeamCity::RunnerUtils
        include ::Rake::TeamCity::Utils::UrlFormatter

        def start
          super
          puts 'Started'
          puts

          # Setup test runner's MessageFactory
          set_message_factory(Rake::TeamCity::MessageFactory)
          log_test_reporter_attached()

          # Report tests count:
          if ::Rake::TeamCity.is_in_idea_mode
            log(@message_factory.create_tests_count(total_count))
          elsif ::Rake::TeamCity.is_in_buildserver_mode
            log(@message_factory.create_progress_message("Starting.. (#{test_count} tests)"))
          end

        end

        def report
          super

          puts('Finished in %.5fs' % total_time)
          print('%d tests, %d assertions, ' % [count, assertions])
          print(red { '%d failures, %d errors, ' } % [failures, errors])
          print(yellow { '%d skips' } % skips)
          puts
        end

        def record(test)
          super
          unless test.passed?
            with_result(test) do |exception_msg, backtrace|
              if test.skipped?
                log(@message_factory.create_test_ignored(test, exception_msg, backtrace))
              elsif test.error?
                log(@message_factory.create_test_error(test, exception_msg, backtrace))
              else
                log(@message_factory.create_test_failed(test, exception_msg, backtrace))
              end
            end
          end
        end

        alias_method :output, :io

        def before_suite(suite)
          fqn = suite.class
          log(@message_factory.create_suite_started(suite.name, location_from_ruby_qualified_name(fqn)))
        end

        def after_suite(suite)
          log(@message_factory.create_suite_finished(suite.name))
        end

        def before_test(test)
          fqn = "#{test.class.name}.#{test.to_s}"
          log(@message_factory.create_test_started(test, minitest_test_location(fqn)))
        end

        def after_test(test)
          log(@message_factory.create_test_finished(test, test.time))
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

        def with_result(test)
          exception = test.failure
          msg = exception.nil? ? "" : "#{exception.class.name}: #{exception.message}"
          backtrace = exception.nil? ? "" : filter_backtrace(exception.backtrace).join("\n")

          yield(msg, backtrace)
        end
      end
    end
  end
end
