require 'test_helper'

class MdnQueryTraverseDomTest < Minitest::Test
  def setup
    @url = 'url'
    @dom = 'Dom'
    @title = 'Title'
    @traverser = ::MdnQuery::TraverseDom.new(@dom, url: @url)
  end

  def test_create_document
    spy = TestUtils::Spy.new
    ::MdnQuery::TraverseDom.stub(:fill_document, spy.method) do
      ::MdnQuery::TraverseDom.create_document(@dom, @title, @url)
      assert spy.called_once?
      call_args = spy.call_args.first
      document = call_args[1]
      assert_equal call_args.first, @dom
      assert_equal document.title, @title
      assert_equal document.url, @url
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

  def test_traverse_sections
    html = '<article><h2 id="sec-one">Section one</h2>'\
      '<h3 id="sub-one">Subsection one</h3>'\
      '<h2 id="sec-two">Section two</h2>'\
      '<h2 id="Specifications">Blacklisted section</h2>'\
      '<h3 id="blacklisted-sub">Blacklisted subsection</h3>'\
      '<h2 id="sec-three">Section three</h2></article>'
    root = traverse_html(html)
    assert_equal root.children.size, 3
    assert_equal @traverser.current_section.name, 'sec-three'
    refute root.to_s =~ /blacklisted/
  end

  def test_traverse_div
    html = '<article><div class="nonStandard">Not standard</div>'\
      '<div class="note">Note</div><div class="warning">Warning</div>'\
      '<div>Missing class</div><div class="other-class">Wrong class</div>'\
      '</article>'
    expected = "# root\n\n> ***Non-standard***\n\n> Note\n\n> Warning"
    root = traverse_html(html)
    assert_equal root.text.size, 3
    assert_equal root.to_s, expected
  end

  def test_traverse_text
    html = '<article><p>Paragraph</p><pre>Code</pre></article>'
    expected = "# root\n\nParagraph\n\n```\nCode\n```"
    root = traverse_html(html)
    assert_equal root.text.size, 2
    assert_equal root.to_s, expected
  end

  def test_traverse_list
    html = '<article><ul><li>One</li><li>Two</li></ul><dl>'\
      '<dt>Definition one</dt><dd>Description one</dd><dt>Definition two</dt>'\
      '<dd>Description two</dd><dl></article>'
    expected = "# root\n\n- One\n- Two\n\n**Definition one**\n\n"\
      "Description one\n\n**Definition two**\n\nDescription two"
    root = traverse_html(html)
    assert_equal root.text.size, 2
    assert_equal root.to_s, expected
  end

  def test_traverse_table
    html = '<article><table><thead><tr><th>First</th><th>Second</th></tr>'\
      '<tbody><tr><td>11</td></tr><tr><td>21</td><td>22</td></tbody></article>'
    expected = "# root\n\n"\
      "| First | Second |\n"\
      "| ----- | ------ |\n"\
      "| 11    |        |\n"\
      '| 21    | 22     |'
    root = traverse_html(html)
    assert_equal root.text.size, 1
    assert_equal root.to_s, expected
  end

  def test_traverse_table_missing_head
    html = '<article><table><tbody><tr><td>11</td></tr><tr><td>21</td>'\
      '<td>22</td></tbody></article>'
    expected = "# root\n\n"\
      "| 11  |     |\n"\
      "| --- | --- |\n"\
      '| 21  | 22  |'
    root = traverse_html(html)
    assert_equal root.text.size, 1
    assert_equal root.to_s, expected
  end

  def test_traverse_code
    html = '<article><pre>Nothing</pre><pre class="brush: html">HTML</pre>'\
      '<pre class="brush:css">CSS</pre><pre class="brush: js">JavaScript</pre>'\
      '<pre class="other-class">Other</pre></article>'
    expected = "# root\n\n```\nNothing\n```\n\n```html\nHTML\n```\n\n"\
      "```css\nCSS\n```\n\n```javascript\nJavaScript\n```\n\n```\nOther\n```"
    root = traverse_html(html)
    assert_equal root.text.size, 5
    assert_equal root.to_s, expected
  end

  private

  def fake_traverse_dom(traverse_spy, document)
    Struct.new(:traverse_spy, :document) do
      def traverse
        traverse_spy.call
      end
    end.new(traverse_spy, document)
  end

  def traverse_html(html)
    @dom = Nokogiri::HTML(html).css('article')
    @traverser = ::MdnQuery::TraverseDom.new(@dom, url: @url)
    @traverser.traverse
    @traverser.document.section
  end
end
