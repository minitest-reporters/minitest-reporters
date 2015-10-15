# This is a test for a bug that was happening when the JUnit Reporter was
# creating filenames from `describe`s that contained slashes, which would crash
# since it was trying to create directories then.

require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use! Minitest::Reporters::JUnitReporter.new

describe 'something/other' do
  it 'does something' do
    1.must_equal 1
  end
end

describe 'something/other' do
  it 'does something else' do
    1.must_equal 2
  end
end
