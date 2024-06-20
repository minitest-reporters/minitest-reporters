require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use! Minitest::Reporters::GithubReporter.new

require_relative 'sample_test'
