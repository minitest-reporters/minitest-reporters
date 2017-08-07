require_relative "../../test_helper"

module MinitestReportersTest
  class MinitestReporterPluginTest < Minitest::Test
    def test_delegates_io
      reporter = Minitest::Reporters::DefaultReporter.new
      io_handle = STDOUT
      dr = Minitest::Reporters::DelegateReporter.new([ reporter ], :io => io_handle)
      assert_equal io_handle, dr.io
      dr.send :all_reporters
      assert_equal io_handle, reporter.io
    end

    def test_casting_to_string_triggers_report
      reporter  = Minitest::Reporters::ProgressReporter.new
      io_handle = StringIO.new
      dr = Minitest::Reporters::DelegateReporter.new([ reporter ], :io => io_handle)

      dr.to_s

      io_handle.rewind
      assert_match(/\d+ tests, \d+ assertions/, io_handle.read)
    end
  end
end
