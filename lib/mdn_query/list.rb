module MdnQuery
  # List of search results
  class List
    attr_reader :query, :items

    def initialize(query, *items)
      items = [] if items.nil?
      @query = query
      @items = items
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
  end
end
