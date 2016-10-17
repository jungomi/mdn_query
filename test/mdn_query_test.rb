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
    stub = TestUtils::Spy.new
    raised_error = ::MdnQuery::NoEntryFound.new(query)
    error_message = 'No entry found'
    ::MdnQuery.stub(:list, stub.throws(raised_error, error_message)) do
      error = assert_raises(::MdnQuery::NoEntryFound) do
        ::MdnQuery.first_match(query)
      end
      assert_equal error.message, error_message
      assert stub.thrown_once?
      assert stub.thrown?(raised_error, error_message)
      assert_equal error.query, query
      assert_equal error.options, {}
    end
  end

  private

  def fake_entry(content)
    Struct.new(:content).new(content)
  end
end
