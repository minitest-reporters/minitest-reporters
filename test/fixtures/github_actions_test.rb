require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/reporters/mean_time_reporter'

Minitest::Reporters.use! Minitest::Reporters::GithubActionsReporter.new

class TestClass < Minitest::Test
  def test_assertion
    assert true
  end

  def test_fail
    if true
      assert false
    end
  end
end
