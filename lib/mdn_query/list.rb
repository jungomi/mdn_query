module MdnQuery
  # A list from a search result.
  class List
    # @return [String] the query that was searched for
    attr_reader :query

    # @return [Array<MdnQuery::Entry>]
    attr_reader :items

    # Creates a new list of search results.
    #
    # @param query [String] the query that was searched for
    # @param items [MdnQuery::Entry] the items in the list
    # @return [MdnQuery::List]
    def initialize(query, *items)
      items = [] if items.nil?
      @query = query
      @items = items
    end

    # Returns the first item in the list.
    #
    # @return [MdnQuery::Entry] the first item
    def first
      items.first
    end

    # Retrieves the item at the given position.
    #
    # @param pos [Fixnum] the position of the item
    # @return [MdnQuery::Entry] the item at position `pos`
    def [](pos)
      items[pos]
    end

    # Returns whether the list is empty.
    #
    # @return [Boolean] whether the list is empty
    def empty?
      items.empty?
    end

    # Returns the number of items in the list.
    #
    # @return [Fixnum] the number of items
    def size
      items.size
    end

    # Calls the given block for every item.
    #
    # @param block [Block] block to be executed for every item.
    # @return [void]
    def each(&block)
      items.each(&block)
    end

    # Returns the string representation of the list.
    #
    # @return [String]
    def to_s
      return "No results for '#{query}'" if empty?
      "Results for '#{query}':\n#{number_items(items).join("\n")}\n"
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
