require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use!(
  Minitest::Reporters::JUnitReporter.new(ENV.fetch('REPORTS_DIR'))
)

# Four tests that each sleep; run concurrently they finish in roughly one
# sleep's worth of wall-clock, far less than the sum of their durations.
class ParallelSuite < Minitest::Test
  parallelize_me!

  SLEEP = 0.4

  def test_a
    sleep SLEEP
    assert true
  end

  def test_b
    sleep SLEEP
    assert true
  end

  def test_c
    sleep SLEEP
    assert true
  end

  def test_d
    sleep SLEEP
    assert true
  end
end
