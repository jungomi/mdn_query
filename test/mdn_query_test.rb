require 'test_helper'

class MdnQueryTest < Minitest::Test
  def test_version_number
    refute_nil ::MdnQuery::VERSION
    assert ::MdnQuery::VERSION > '0.0.0'
  end

  def test_first_match
    content = 'Content'
    entries = [fake_entry(content)]
    stub = TestUtils::Spy.new(entries)
    ::MdnQuery.stub(:list, stub.method) do
      first = ::MdnQuery.first_match('Query')
      assert_equal first, content
    end
  end

  def test_first_match_no_entry
    stub = TestUtils::Spy.new([])
    ::MdnQuery.stub(:list, stub.method) do
      error = assert_raises(RuntimeError) { ::MdnQuery.first_match('Query') }
      assert_equal error.message, 'No entry found'
    end
  end

  private

  def fake_entry(content)
    Struct.new(:content).new(content)
  end
end
