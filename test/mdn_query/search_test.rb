require 'test_helper'

class MdnQuerySearchTest < Minitest::Test
  def setup
    @query = 'Query'
    @search = ::MdnQuery::Search.new(@query)
  end

  def test_url
    expected_url = "#{url}.json?q=Query&locale=en-US&topic=js&highlight=false"
    assert_equal @search.url, expected_url
  end

  def test_url_with_highlight_nil
    @search.highlight = nil
    expected_url = "#{url}.json?q=Query&locale=en-US&topic=js"
    assert_equal @search.url, expected_url
  end

  def test_url_with_html_attributes
    @search.html_attributes = 'html'
    expected_url = "#{url}.json?q=Query&locale=en-US&topic=js"\
      '&html_attributes=html&highlight=false'
    assert_equal @search.url, expected_url
  end

  def test_url_with_css_classnames
    @search.css_classnames = 'css'
    expected_url = "#{url}.json?q=Query&locale=en-US&topic=js"\
      '&css_classnames=css&highlight=false'
    assert_equal @search.url, expected_url
  end

  def test_execute
    result = 'Result'
    expected_url = "#{url}.json?q=Query&locale=en-US&topic=js&highlight=false"
    spy = TestUtils::Spy.new(result)
    @search.stub(:retrieve, spy.method) do
      assert @search.result.nil?
      @search.execute
      assert spy.called_once?
      assert spy.called_with_args?(expected_url, @query)
      assert_equal @search.result, result
    end
  end

  def test_next_page_nil
    spy_execute_retrieve do |execute, retrieve|
      assert @search.result.nil?
      @search.next_page
      assert execute.called_once?
      refute retrieve.called?
    end
  end

  def test_next_page_with_next
    expected_url = "#{url}.json?q=Query&locale=en-US&topic=js&highlight=false"\
      '&page=2'
    @search.result = fake_result(false, true, 1)
    spy_execute_retrieve do |execute, retrieve|
      assert @search.result.next?
      @search.next_page
      refute execute.called?
      assert retrieve.called_once?
      assert retrieve.called_with_args?(expected_url, @query)
    end
  end

  def test_next_page_without_next
    @search.result = fake_result(false, false, 5)
    spy_execute_retrieve do |execute, retrieve|
      refute @search.result.next?
      @search.next_page
      refute execute.called?
      refute retrieve.called?
    end
  end

  def test_previous_page_nil
    spy_execute_retrieve do |execute, retrieve|
      assert @search.result.nil?
      @search.previous_page
      assert execute.called_once?
      refute retrieve.called?
    end
  end

  def test_previous_page_with_previous
    expected_url = "#{url}.json?q=Query&locale=en-US&topic=js&highlight=false"\
      '&page=4'
    @search.result = fake_result(true, false, 5)
    spy_execute_retrieve do |execute, retrieve|
      assert @search.result.previous?
      @search.previous_page
      refute execute.called?
      assert retrieve.called_once?
      assert retrieve.called_with_args?(expected_url, @query)
    end
  end

  def test_previous_page_without_previous
    @search.result = fake_result(false, false, 1)
    spy_execute_retrieve do |execute, retrieve|
      refute @search.result.previous?
      @search.previous_page
      refute execute.called?
      refute retrieve.called?
    end
  end

  def test_open
    expected_url = "#{url}?q=Query&locale=en-US&topic=js&highlight=false"
    spy = TestUtils::Spy.new
    Launchy.stub(:open, spy.method) { @search.open }
    assert spy.called_once?
    assert spy.called_with_args?(expected_url)
  end

  private

  def spy_execute_retrieve
    execute_spy = TestUtils::Spy.new
    retrieve_spy = TestUtils::Spy.new
    @search.stub(:execute, execute_spy.method) do
      @search.stub(:retrieve, retrieve_spy.method) do
        yield execute_spy, retrieve_spy
      end
    end
  end

  def fake_result(prev, nex, page)
    Struct.new(:prev, :nex, :page) do
      def previous?
        prev
      end

      def next?
        nex
      end

      def current_page
        page
      end
    end.new(prev, nex, page)
  end

  def url
    ::MdnQuery::BASE_URL
  end
end
