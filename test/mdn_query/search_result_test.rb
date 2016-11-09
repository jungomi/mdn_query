require 'test_helper'

class MdnQuerySearchResultTest < Minitest::Test
  def setup
    @query = 'Query'
    @documents = create_documents(4)
    @json = {
      pages: 5,
      page: 2,
      count: 20,
      documents: @documents
    }
    @search_result = ::MdnQuery::SearchResult.new(@query, @json)
  end

  def test_empty?
    empty_document = ::MdnQuery::SearchResult.new(@query, pages: 0)
    refute @search_result.empty?
    assert empty_document.empty?
  end

  def test_next?
    last_page = ::MdnQuery::SearchResult.new(@query, page: 5, pages: 5)
    assert @search_result.next?
    refute last_page.next?
  end

  def test_previous?
    first_page = ::MdnQuery::SearchResult.new(@query, pages: 5, page: 1)
    assert @search_result.previous?
    refute first_page.previous?
  end

  def test_current_page
    assert_equal @search_result.current_page, @json[:page]
  end

  def test_to_list
    spy = TestUtils::Spy.new('Item')
    ::MdnQuery::Entry.stub(:new, spy.method) do
      list = @search_result.to_list
      assert list.instance_of?(::MdnQuery::List)
      assert spy.called_times?(@documents.size)
      @documents.each do |doc|
        assert spy.called_with_args?(doc[:title], doc[:excerpt], doc[:url])
      end
    end
  end

  def test_from_url
    json = {
      query: @query,
      pages: 10,
      page: 1,
      count: 100,
      documents: %w(doc1 doc2 doc3)
    }
    fake_response = Struct.new(:body).new(JSON.generate(json))
    spy = TestUtils::Spy.new(fake_response)
    RestClient::Request.stub(:execute, spy.method) do
      result = ::MdnQuery::SearchResult.from_url(@url)
      assert spy.called_once?
      assert result.instance_of?(::MdnQuery::SearchResult)
      assert_equal result.query, @query
      assert_equal result.items, json[:documents]
    end
  end

  def test_from_url_throws
    spy = TestUtils::Spy.new
    RestClient::Request.stub(:execute, spy.throws(RestClient::Exception)) do
      error = assert_raises(::MdnQuery::HttpRequestFailed) do
        ::MdnQuery::SearchResult.from_url(@url)
      end
      assert_equal error.message, 'Could not retrieve search result'
      assert spy.thrown_once?
      assert_equal error.url, @url
    end
  end

  private

  def create_documents(num)
    (1..num).map do |n|
      {
        title: "Document #{n}",
        excerpt: "Excerpt of document #{n}",
        url: "url#{n}"
      }
    end
  end
end
