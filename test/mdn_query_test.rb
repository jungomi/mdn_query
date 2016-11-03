require 'test_helper'

class MdnQueryTest < Minitest::Test
  def setup
    @query = 'Query'
  end

  def test_version_number
    refute_nil ::MdnQuery::VERSION
    assert ::MdnQuery::VERSION > '0.0.0'
  end

  def test_list
    expected = %w(one two three)
    spy = TestUtils::Spy.new(fake_search(expected))
    ::MdnQuery::Search.stub(:new, spy.method) do
      list = ::MdnQuery.list(@query)
      assert spy.called_once?
      assert spy.called_with_args?(@query, {})
      assert list, expected
    end
  end

  def test_list_empty
    spy = TestUtils::Spy.new(fake_search([]))
    ::MdnQuery::Search.stub(:new, spy.method) do
      error = assert_raises(::MdnQuery::NoEntryFound) do
        ::MdnQuery.list(@query)
      end
      assert spy.called_once?
      assert spy.called_with_args?(@query, {})
      assert error.message, 'No entry found'
    end
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
    stub = TestUtils::Spy.new
    raised_error = ::MdnQuery::NoEntryFound.new(@query)
    error_message = 'No entry found'
    ::MdnQuery.stub(:list, stub.throws(raised_error, error_message)) do
      error = assert_raises(::MdnQuery::NoEntryFound) do
        ::MdnQuery.first_match(@query)
      end
      assert_equal error.message, error_message
      assert stub.thrown_once?
      assert stub.thrown?(raised_error, error_message)
      assert_equal error.query, @query
      assert_equal error.options, {}
    end
  end

  def test_open_list
    url = "https://developer.mozilla.org/search?q=#{@query}&locale=en-US"\
      '&topic=js&highlight=false'
    spy = TestUtils::Spy.new
    Launchy.stub(:open, spy.method) { ::MdnQuery.open_list(@query) }
    assert spy.called_once?
    assert spy.called_with_args?(url)
  end

  def test_open_first_match
    url = 'url'
    list = [::MdnQuery::Entry.new('title', 'description', url)]
    spy = TestUtils::Spy.new
    stub = TestUtils::Spy.new(list)
    ::MdnQuery.stub(:list, stub.method) do
      Launchy.stub(:open, spy.method) { ::MdnQuery.open_first_match(@query) }
    end
    assert stub.called_once?
    assert stub.called_with_args?(@query, {})
    assert spy.called_once?
    assert spy.called_with_args?(url)
  end

  private

  def fake_entry(content)
    Struct.new(:content).new(content)
  end

  def fake_search(list)
    result = Struct.new(:to_list).new(list)
    Struct.new(:execute).new(result)
  end
end
