module MdnQuery
  # A table in a document
  class Table
    attr_reader :body, :heading, :size

    def initialize(heading, *rows)
      @heading = heading
      @size = heading.size
      @body = []
      rows.each { |row| add_row(row) }
    end

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

    def cols
      @size
    end

    def rows
      @body.size
    end

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
      rows = @body.map { |row| "| #{pad_cols(row, col_sizes).join(' | ')} |" }
      "#{rows.join("\n")}\n"
    end

    def separator(col_sizes)
      "| #{col_sizes.map { |size| '-' * size }.join(' | ')} |\n"
    end
  end
end
