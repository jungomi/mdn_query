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
    ::MdnQuery::Document.stub(:from_url, spy.method) do
      refute spy.called?
      @entry.content
      assert spy.called_once?
      assert_equal @entry.content, content
      @entry.content
    end
    assert spy.called_once?
    assert_equal @entry.content, content
  end
end
