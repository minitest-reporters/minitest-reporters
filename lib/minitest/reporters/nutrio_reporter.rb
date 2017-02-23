require 'ansi/code'

class NutrioReporter < Minitest::Reporters::BaseReporter
  def initialize(options = {})
    super
    @suite_times = []
    @suite_start_times = {}
    @options = options
  end

  def start
    super
    puts
    puts("# Running tests with run options %s:" % options[:args])
    puts
  end

  def before_suite(suite)
    @suite_start_times[suite] = Time.current
    super
  end

  def after_suite(suite)
    super
    @suite_times << [suite.name, Time.current - @suite_start_times.delete(suite)]
  end

  def record(test)
    super
    print(if test.passed?
      record_pass(test)
    elsif test.skipped?
      record_skip(test)
    elsif test.failure
      record_failure(test)
    end)

    if test.failure && !test.skipped?
      puts
      print_failure(test)
    end
  end

  def record_pass(test)
    green('.')
  end

  def record_skip(test)
    yellow('S')
  end

  def record_failure(test)
    red('F')
  end

  def report
    super
    status_line = "Finished tests in %s, %.1f tests/s, %.1f assertions/s." %
      [ameliorated_time_string(total_time), count / total_time, assertions / total_time]
    puts
    puts colored_for(suite_result, status_line)

    puts
    print colored_for(suite_result, result_line)
    puts
  end

  def print_failure(test)
    puts colored_for(result(test), message_for(test))
  end

  private

  def ameliorated_time_string(seconds)
    hours = seconds / 3600
    mins  = seconds / 60 % 60
    secs  = seconds % 60
    [
      hours >= 1 ? ("%.0dh" % hours) : '',
      mins  >= 1 ? ("%.0dm" % mins) : '',
      "%.2fs" % secs
    ].join(' ')
  end

  def green(string)
    ANSI::Code.green(string)
  end

  def yellow(string)
    ANSI::Code.yellow(string)
  end

  def red(string)
    ANSI::Code.red(string)
  end

  def colored_for(result, string)
    case result
    when :fail, :error; red(string)
    when :skip; yellow(string)
    else green(string)
    end
  end

  def suite_result
    case
    when failures > 0; :fail
    when errors > 0; :error
    when skips > 0; :skip
    else :pass
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

  def message_for(test)
    e = test.failure

    if test.skipped?
      nil #no message for skipped
    elsif test.error?
      "Error:\n#{test.class}##{test.name}:\n#{e.message}"
    else
      "Failure:\n#{test.class}##{test.name} [#{test.failure.location}]\n#{e.class}: #{e.message}"
    end
  end

  def result_line
    '%d tests, %d assertions, %d failures, %d errors, %d skips' %
      [count, assertions, failures, errors, skips]
  end
end
