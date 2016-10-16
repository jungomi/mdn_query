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
end
