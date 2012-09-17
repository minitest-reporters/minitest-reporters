require_relative "../test_helper"

module MiniTestReportersTest
  class GoodTest < TestCase
    def test_a
      assert_equal 1, 1
      assert 1
    end

    def test_b
      assert_equal 2, 2
    end
  end
end
