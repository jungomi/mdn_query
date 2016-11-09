require 'test_helper'

class MdnQueryDocumentTest < Minitest::Test
  def setup
    @title = 'Title'
    @url = 'url'
    @document = ::MdnQuery::Document.new(@title, @url)
  end

  def test_open
    spy = TestUtils::Spy.new
    Launchy.stub(:open, spy.method) { @document.open }
    assert spy.called_once?
    assert spy.called_with_args?(@url)
  end

  def test_open_nil
    spy = TestUtils::Spy.new
    document = ::MdnQuery::Document.new(@title)
    Launchy.stub(:open, spy.method) { document.open }
    refute spy.called?
  end

  def test_to_s
    output = 'Section'
    spy = TestUtils::Spy.new(output)
    @document.section.stub(:to_s, spy.method) do
      str = @document.to_s
      assert spy.called_once?
      assert_equal str, output
    end
  end

  def test_from_url_throws
    spy = TestUtils::Spy.new
    RestClient::Request.stub(:execute, spy.throws(RestClient::Exception)) do
      error = assert_raises(::MdnQuery::HttpRequestFailed) do
        ::MdnQuery::Document.from_url(@url)
      end
      assert_equal error.message, 'Could not retrieve entry'
      assert spy.thrown_once?
      assert_equal error.url, @url
    end
  end

  def test_from_url
    title = 'Document title'
    html = "<html><body><h1>#{title}</h1><article></article></body></html>"
    fake_response = Struct.new(:body).new(html)
    spy = TestUtils::Spy.new(fake_response)
    RestClient::Request.stub(:execute, spy.method) do
      result = ::MdnQuery::Document.from_url(@url)
      assert spy.called_once?
      assert result.instance_of?(::MdnQuery::Document)
      assert_equal result.title, title
      assert_equal result.url, @url
    end
  end
end
