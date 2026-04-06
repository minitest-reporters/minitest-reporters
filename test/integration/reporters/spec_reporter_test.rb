require_relative "../../test_helper"

module MinitestReportersTest
  class SpecReporterIntegrationTest < TestCase
    def test_with_progress_option
      fixtures_directory = File.expand_path('../../../fixtures', __FILE__)
      test_filename = File.join(fixtures_directory, 'spec_with_progress_test.rb')
      output = `#{ruby_executable} #{test_filename} 2>&1`
      assert_match "[0001/0002] test_0001", output, 'Progress should be displayed in test line 1'
      assert_match "[0002/0002] test_0002", output, 'Progress should be displayed in test line 2'

    end

    private

    def ruby_executable
      defined?(JRUBY_VERSION) ? 'jruby' : 'ruby'
    end
  end
end
