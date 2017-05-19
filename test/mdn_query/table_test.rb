require 'test_helper'

class MdnQueryTableTest < Minitest::Test
  def setup
    @heading = %w[Title Description]
    @table = ::MdnQuery::Table.new(@heading)
  end

  def test_add_row_of_same_size
    row = %w[One Number]
    size_before = @table.size
    rows_before = @table.rows
    @table.add_row(row)
    assert_equal @table.size, size_before
    assert_equal @table.rows, rows_before + 1
    assert_equal @table.body.last, row
  end

  def test_add_row_of_smaller_size
    row = ['One']
    expected_row = ['One', '']
    size_before = @table.size
    rows_before = @table.rows
    @table.add_row(row)
    assert_equal @table.size, size_before
    assert_equal @table.rows, rows_before + 1
    assert_equal @table.body.last, expected_row
  end

  def test_add_row_of_bigger_size
    row = %w[One Number More]
    expected_heading = [*@table.heading, '']
    rows_before = @table.rows
    @table.add_row(row)
    assert_equal @table.size, row.size
    assert_equal @table.rows, rows_before + 1
    assert_equal @table.body.last, row
    assert_equal @table.heading, expected_heading
  end

  def test_to_s_without_body
    expected = "| Title | Description |\n"\
               "| ----- | ----------- |\n"
    assert_equal @table.to_s, expected
  end

  def test_to_s_with_body
    row = ['One', 'Long description']
    table = ::MdnQuery::Table.new(@heading, row)
    expected = "| Title | Description      |\n"\
               "| ----- | ---------------- |\n"\
               "| One   | Long description |\n"
    assert_equal table.to_s, expected
  end
end
