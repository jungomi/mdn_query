require 'test_helper'

class MdnQueryListTest < Minitest::Test
  def setup
    @query = 'Query'
    @empty_list = ::MdnQuery::List.new(@query)
    @items = ['Item one', 'Item two', 'Item three']
    @list = ::MdnQuery::List.new(@query, *@items)
  end

  def test_empty?
    assert @empty_list.empty?
    refute @list.empty?
  end

  def test_first
    assert @empty_list.first.nil?
    assert_equal @list.first, @items.first
  end

  def test_size
    assert_equal @empty_list.size, 0
    assert_equal @list.size, @items.size
  end

  def test_array_access
    assert @empty_list[0].nil?
    assert_equal @list[0], @list[0]
    assert @list[10].nil?
  end

  def test_each
    spy = TestUtils::Spy.new
    @list.each { |item| spy.method.call(item) }
    assert spy.called?
    assert spy.called_times?(@list.items.size)
    @list.items.each { |item| assert spy.called_with_args?(item) }
  end

  def test_to_s
    expected = "Results for 'Query':\n"\
               "1) Item one\n"\
               "2) Item two\n"\
               "3) Item three\n"
    assert_equal @list.to_s, expected
  end

  def test_to_s_double_digits
    items = (1..10).map(&:to_s)
    list = ::MdnQuery::List.new(@query, *items)
    expected = "Results for 'Query':\n"\
               " 1) 1\n"\
               " 2) 2\n"\
               " 3) 3\n"\
               " 4) 4\n"\
               " 5) 5\n"\
               " 6) 6\n"\
               " 7) 7\n"\
               " 8) 8\n"\
               " 9) 9\n"\
               "10) 10\n"
    assert_equal list.to_s, expected
  end

  def test_to_s_empty
    expected = "No results for 'Query'"
    assert_equal @empty_list.to_s, expected
  end
end
