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
