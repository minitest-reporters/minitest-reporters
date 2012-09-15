require "bundler/setup"
require "minitest/autorun"
require "rr"
require "minitest/reporters"
MiniTest::Reporters.use!

module MiniTestReportersTest
  class TestCase < MiniTest::Unit::TestCase
    include RR::Adapters::MiniTest
  end
end

# Testing the built-in reporters using automated unit testing would be extremely
# brittle. Consequently, there are no unit tests for them.  If you'd like to run
# all the reporters sequentially on a fake test suite, run `rake gallery`.
