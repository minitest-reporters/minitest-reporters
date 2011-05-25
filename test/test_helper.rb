require 'bundler/setup'
require 'minitest/autorun'
require 'mocha'
require 'test_declarative'
require 'minitest-reporter'

module MiniTestReporterTest
  require './test/support/test_case'
  
  module Fixtures
    require './test/support/fixtures/test_case_fixture'
    require './test/support/fixtures/empty_test_fixture'
    require './test/support/fixtures/error_test_fixture'
    require './test/support/fixtures/failure_test_fixture'
    require './test/support/fixtures/pass_test_fixture'
    require './test/support/fixtures/skip_test_fixture'
    require './test/support/fixtures/suite_callback_test_fixture'
  end
end