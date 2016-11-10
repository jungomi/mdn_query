require 'test_helper'

class MdnQuerySectionTest < Minitest::Test
  def setup
    @name = 'Section'
    @section = ::MdnQuery::Section.new(@name)
  end

  def test_create_child
    expected_level = @section.level + 1
    expected_children_size = @section.children.size + 1
    child = @section.create_child('Child')
    assert_equal child.level, expected_level
    assert_equal child.parent, @section
    assert_equal @section.children.size, expected_children_size
    assert_equal @section.children.last, child
  end

  def test_append_text
    expected_text_size = @section.text.size + 1
    text = 'Text to append'
    @section.append_text(text)
    assert_equal @section.text.size, expected_text_size
    assert_equal @section.text.last, text
  end

  def test_append_text_blank
    expected_text_size = @section.text.size
    text = "        \n     \t   \n   "
    @section.append_text(text)
    assert_equal @section.text.size, expected_text_size
  end

  def test_append_text_spaces_after_newline
    expected_text_size = @section.text.size + 1
    text = "Text to append\n        Another line"
    expected_text = "Text to append\nAnother line"
    @section.append_text(text)
    assert_equal @section.text.size, expected_text_size
    assert_equal @section.text.last, expected_text
  end

  def test_append_text_spaces_before_newline
    expected_text_size = @section.text.size + 1
    text = "Text to append   \nAnother line"
    expected_text = "Text to append\nAnother line"
    @section.append_text(text)
    assert_equal @section.text.size, expected_text_size
    assert_equal @section.text.last, expected_text
  end

  def test_append_text_html_tags
    expected_text_size = @section.text.size + 1
    text = '<tag> is useful in <other>'
    expected_text = '`<tag>` is useful in `<other>`'
    @section.append_text(text)
    assert_equal @section.text.size, expected_text_size
    assert_equal @section.text.last, expected_text
  end

  def test_append_code
    expected_text_size = @section.text.size + 1
    text = 'const num = 42'
    expected_text = "\n```\nconst num = 42\n```\n"
    @section.append_code(text)
    assert_equal @section.text.size, expected_text_size
    assert_equal @section.text.last, expected_text
  end

  def test_append_code_language
    expected_text_size = @section.text.size + 1
    text = 'const num = 42'
    expected_text = "\n```javascript\nconst num = 42\n```\n"
    @section.append_code(text, language: 'javascript')
    assert_equal @section.text.size, expected_text_size
    assert_equal @section.text.last, expected_text
  end

  def test_append_code_blank
    expected_text_size = @section.text.size
    text = "        \n     \t   \n   "
    @section.append_code(text)
    assert_equal @section.text.size, expected_text_size
  end

  def test_to_s
    text = "Text to append\n\n\n\nNon empty\n  \t   \nTrailing newline\n"
    expected_text = "# Section\n\nText to append\n\nNon empty\n\n"\
      'Trailing newline'
    @section.append_text(text)
    assert_equal @section.to_s, expected_text
  end

  def test_to_s_blank
    expected_text = '# Section'
    assert_equal @section.to_s, expected_text
  end

  def test_to_s_with_children
    expected_text = "# Section\n\n## Subsection"
    @section.create_child('Subsection')
    assert_equal @section.to_s, expected_text
  end
end
