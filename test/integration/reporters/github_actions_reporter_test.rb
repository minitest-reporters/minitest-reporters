require_relative "../../test_helper"

module MinitestReportersTest
  class GithubActionsReporterTest < TestCase
    def test_output_format
      fixtures_directory = File.expand_path('../../fixtures', __dir__)
      test_filename = File.join(fixtures_directory, 'github_actions_test.rb')
      output = `ruby #{test_filename} 2>&1`
      refute_match 'test_assertion', output
      assert_match '::error file=test/fixtures/github_actions_test.rb,line=15::Failure: test_fail', output
    end
  end
end
