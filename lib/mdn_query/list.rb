module MdnQuery
  # List of search results
  class List
    attr_reader :query, :items

    def initialize(query, *items)
      items = [] if items.nil?
      @query = query
      @items = items
    end

    def first
      items.first
    end

    def [](pos)
      items[pos]
    end

    def empty?
      items.empty?
    end

    def size
      items.size
    end

    def each(&block)
      items.each(&block)
    end

    def to_s
      "Results for '#{query}':\n#{number_items(items).join("\n")}"
    end

    private

    def number_items(items)
      num_width = items.size / 10 + 1

      items.map.with_index do |item, index|
        entry = "#{(index + 1).to_s.rjust(num_width)}) "
        entry << pad_left(item.to_s, num_width + 2)
      end
    end

    def pad_left(str, num)
      pad = ' ' * num
      str.gsub("\n", "\n#{pad}")
    end
  end
end
