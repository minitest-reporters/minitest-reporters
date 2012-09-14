require File.expand_path("../test_helper", __FILE__)

class GoodTest < MiniTest::Unit::TestCase
  def test_a
    assert_equal 1, 1
    assert 1
  end

  def test_b
    assert_equal 2, 2
  end
end
