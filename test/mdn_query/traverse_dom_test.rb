require 'test_helper'

class MdnQueryTraverseDomTest < Minitest::Test
  def setup
    @dom = 'Dom'
    @title = 'Title'
    @traverser = ::MdnQuery::TraverseDom.new(@dom, url: @url)
  end

  def test_create_document
    url = 'url'
    spy = TestUtils::Spy.new
    ::MdnQuery::TraverseDom.stub(:fill_document, spy.method) do
      ::MdnQuery::TraverseDom.create_document(@dom, @title, url)
      assert spy.called_once?
      call_args = spy.call_args.first
      document = call_args[1]
      assert_equal call_args.first, @dom
      assert_equal document.title, @title
      assert_equal document.url, url
    end
  end

  def test_fill_document
    document = 'Document'
    traverse_spy = TestUtils::Spy.new
    fake_traverse = fake_traverse_dom(traverse_spy.method, document)
    new_spy = TestUtils::Spy.new(fake_traverse)
    ::MdnQuery::TraverseDom.stub(:new, new_spy.method) do
      doc = ::MdnQuery::TraverseDom.fill_document(@dom, document)
      assert new_spy.called_once?
      assert new_spy.called_with_args?(@dom, document: document)
      assert traverse_spy.called_once?
      assert doc, document
    end
  end

  def test_create_child_parent
    spy = TestUtils::Spy.new
    name = 'Child name'
    @traverser.document.section.stub(:create_child, spy.method) do
      @traverser.create_child(1, name)
      assert spy.called_once?
      assert spy.called_with_args?(name)
    end
  end

  def test_blacklisted?
    not_included = 'Something that is not included'
    refute @traverser.blacklisted?(not_included)
    ::MdnQuery::TraverseDom::BLACKLIST.each do |item|
      assert @traverser.blacklisted?(item)
    end
  end

  private

  def fake_traverse_dom(traverse_spy, document)
    Struct.new(:traverse_spy, :document) do
      def traverse
        traverse_spy.call
      end
    end.new(traverse_spy, document)
  end
end
