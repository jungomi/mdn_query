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
    query = 'Query'
    stub = TestUtils::Spy.new([])
    ::MdnQuery.stub(:list, stub.method) do
      error = assert_raises(::MdnQuery::NoEntryFound) do
        ::MdnQuery.first_match(query)
      end
      assert_equal error.message, 'No entry found'
      assert_equal error.query, query
      assert_equal error.options, {}
    end
  end

  private

  def fake_entry(content)
    Struct.new(:content).new(content)
  end
end
