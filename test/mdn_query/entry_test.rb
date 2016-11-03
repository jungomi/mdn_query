require 'test_helper'

class MdnQueryEntryTest < Minitest::Test
  def setup
    @title = 'Title'
    @description = 'Description'
    @url = 'url'
    @entry = ::MdnQuery::Entry.new(@title, @description, @url)
  end

  def test_to_s
    expected_text = "Title\nDescription\nurl"
    assert_equal @entry.to_s, expected_text
  end

  def test_open
    spy = TestUtils::Spy.new
    Launchy.stub(:open, spy.method) { @entry.open }
    assert spy.called_once?
    assert spy.called_with_args?(@url)
  end

  def test_content
    content = 'Content'
    spy = TestUtils::Spy.new(content)
    @entry.stub(:retrieve, spy.method) do
      refute spy.called?
      @entry.content
      assert spy.called_once?
      assert_equal @entry.content, content
      @entry.content
    end
    assert spy.called_once?
    assert_equal @entry.content, content
  end

  def test_retrieve_throws
    spy = TestUtils::Spy.new
    RestClient::Request.stub(:execute, spy.throws(RestClient::Exception)) do
      error = assert_raises(::MdnQuery::HttpRequestFailed) do
        @entry.send(:retrieve, @url)
      end
      assert_equal error.message, 'Could not retrieve entry'
      assert spy.thrown_once?
      assert_equal error.url, @url
    end
  end

  def test_retrieve
    title = 'Document title'
    html = "<html><body><h1>#{title}</h1><article></article></body></html>"
    fake_response = Struct.new(:body).new(html)
    spy = TestUtils::Spy.new(fake_response)
    RestClient::Request.stub(:execute, spy.method) do
      result = @entry.send(:retrieve, @url)
      assert spy.called_once?
      assert result.instance_of?(::MdnQuery::Document)
      assert_equal result.title, title
      assert_equal result.url, @url
    end
  end
end
