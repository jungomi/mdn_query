module MdnQuery
  # A symmetric table with a nicely aligned textual representation.
  #
  # The table automatically adjusts rows that are too small by padding them with
  # empty strings.
  class Table
    # @return [Array<Array<String>>] the body (list of rows) of the table
    attr_reader :body

    # @return [Array<String>] the heading of the table
    attr_reader :heading

    # @return [Fixnum] the number of columns in the table
    attr_reader :size

    # Creates a new table.
    #
    # @param heading [Array<String>] the heading of the table
    # @param rows [Array<String>] rows to add to the body
    # @return [MdnQuery::Table]
    def initialize(heading, *rows)
      @heading = heading
      @size = heading.size
      @body = []
      rows.each { |row| add_row(row) }
    end

    # Adds a row to the body of the table.
    #
    # When the size of the row is smaller than the current table size, it is
    # padded with empty strings to that size.
    # When the size is greater than the current table size, the entire table is
    # padded with empty strings to that size.
    #
    # @param row [Array<String>] the row to add
    # @return [void]
    def add_row(row)
      if row.size < @size
        row.fill('', row.size...@size)
      elsif row.size > @size
        @heading.fill('', @size...row.size)
        @body.each { |r| r.fill('', @size...row.size) }
        @size = row.size
      end
      @body << row
    end

    # Returns the number of columns in the table.
    #
    # @return [Fixnum]
    def cols
      @size
    end

    # Returns the number of rows in the body of the table.
    #
    # @return [Fixnum]
    def rows
      @body.size
    end

    # Returns the string representation of the table.
    #
    # This representation is a Markdown table that is aligned nicely, so that it
    # is also easy to read in its raw format.
    #
    # @example Small table
    #   | Title | Description      |
    #   | ----- | ---------------- |
    #   | One   |                  |
    #   | Two   | Long description |
    #
    # @return [String]
    def to_s
      return '' if cols < 1
      col_sizes = max_col_sizes
      str = heading_str(col_sizes)
      str << separator(col_sizes)
      str << body_str(col_sizes)
      str
    end

    private

    def max_col_sizes
      max_sizes = @heading.map { |col| col.size > 3 ? col.size : 3 }
      @body.each do |row|
        row.each.with_index do |str, index|
          next unless str.size > max_sizes[index]
          max_sizes[index] = str.size
        end
      end
      max_sizes
    end

    def pad_cols(row, col_sizes)
      row.map.with_index { |col, index| col.ljust(col_sizes[index]) }
    end

    def heading_str(col_sizes)
      "| #{pad_cols(@heading, col_sizes).join(' | ')} |\n"
    end

    def body_str(col_sizes)
      return '' if @body.empty?
      rows = @body.map { |row| "| #{pad_cols(row, col_sizes).join(' | ')} |" }
      "#{rows.join("\n")}\n"
    end

    def separator(col_sizes)
      "| #{col_sizes.map { |size| '-' * size }.join(' | ')} |\n"
    end
  end
end
