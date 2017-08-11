require 'minitest'
require 'minitest/reporters'
require 'minitest/autorun'

Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

describe String do
  describe '#length' do
    it 'works' do
      assert_equal 5, 'hello'.length
    end
  end
end
