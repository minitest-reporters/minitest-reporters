class TestClass < Minitest::Test
  def test_assertion
    assert true
  end

  def test_fail
    assert false
  end
end

class AnotherTestClass < Minitest::Test
  def test_assertion
    assert true
  end

  def test_skip
    skip 'Skipping rope...'
  end
end

class LastTestClass < Minitest::Test
  def test_assertion
    assert true
  end

  def test_error
    raise 'An unexpected error'
  end
end
