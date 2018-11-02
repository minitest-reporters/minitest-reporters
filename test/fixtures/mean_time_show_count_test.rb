require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/reporters/mean_time_reporter'

Minitest::Reporters.use! Minitest::Reporters::MeanTimeReporter.new(show_count: 3)

require_relative './separate_sample_test'
