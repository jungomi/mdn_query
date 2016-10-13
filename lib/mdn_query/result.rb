Item = Struct.new(:title, :description, :url) do
  def to_s
    "#{title}\n#{description}\n#{url}"
  end
end

module MdnQuery
  # A search result
  class Result
    attr_reader :items, :pages, :query, :response, :total

    def initialize(query, response)
      @query = query
      @response = response
      json = response.to_h
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
      items = @items.map { |i| Item.new(i[:title], i[:excerpt], i[:url]) }
      MdnQuery::List.new(query, *items)
    end
  end
end
