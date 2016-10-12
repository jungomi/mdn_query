module MdnQuery
  # A search result
  class Result
    attr_reader :items, :pages, :response, :total

    def initialize(response)
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

    def current
      @pages[:current]
    end
  end
end
