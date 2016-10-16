module MdnQuery
  # A result from a search query
  class SearchResult
    attr_reader :items, :pages, :query, :total

    def initialize(query, json)
      @query = query
      @pages = {
        count: json[:pages] || 0,
        current: json[:page],
        range: json[:start]..json[:end]
      }
      @total = json[:count]
      @items = json[:documents]
    end

    def empty?
      @pages[:count].zero?
    end

    def next?
      !empty? && @pages[:current] < @pages[:range].last
    end

    def previous?
      !empty? && @pages[:current] > @pages[:range].first
    end

    def current_page
      @pages[:current]
    end

    def to_list
      items = @items.map do |i|
        MdnQuery::Entry.new(i[:title], i[:excerpt], i[:url])
      end
      MdnQuery::List.new(query, *items)
    end
  end
end
