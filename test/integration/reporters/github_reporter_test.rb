require_relative "../../test_helper"

module MinitestReportersTest
  class GithubReporterTest < TestCase
    def test_failure_displayed
      fixtures_directory = File.expand_path('../../fixtures', __dir__)
      test_filename = File.join(fixtures_directory, 'github_test.rb')
      output = `#{ruby_executable} #{test_filename} 2>&1`
      assert_match "::error file=test/fixtures/sample_test.rb,line=12,title=test_error::Unexpected exception", output
      assert_match "::error file=test/fixtures/sample_test.rb,line=6,title=test_failure::Expected false to be truthy.", output
      assert_match "::notice file=test/fixtures/sample_test.rb,line=8,title=test_skip::Skipping rope", output
    end

    private

    def ruby_executable
      defined?(JRUBY_VERSION) ? 'jruby' : 'ruby'
    end
  end
end
