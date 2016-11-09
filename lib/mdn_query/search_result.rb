module MdnQuery
  # A result from a search query.
  class SearchResult
    # @return [Array<Hash>] the raw items of the search result
    attr_reader :items

    # @return [Hash] information about the pages
    attr_reader :pages

    # @return [String] the query that was searched for
    attr_reader :query

    # @return [Fixnum] the total number of entries
    attr_reader :total

    # Creates a search result with the results from the URL.
    #
    # @param url [String] the URL to the search result on the web
    # @return [MdnQuery::SearchResult]
    def self.from_url(url)
      begin
        response = RestClient::Request.execute(method: :get, url: url,
                                               headers: { accept: 'json' })
      rescue RestClient::Exception, SocketError => e
        raise MdnQuery::HttpRequestFailed.new(url, e),
              'Could not retrieve search result'
      end
      json = JSON.parse(response.body, symbolize_names: true)
      new(json[:query], json)
    end

    # Creates a new search result.
    #
    # @param query [String] the query that was searched for
    # @param json [Hash] the hash version of the JSON response
    # @return [MdnQuery::SearchResult]
    def initialize(query, json)
      @query = query
      @pages = {
        count: json[:pages] || 0,
        current: json[:page]
      }
      @total = json[:count]
      @items = json[:documents]
    end

    # Returns whether there are any entries.
    #
    # @return [Boolean]
    def empty?
      @pages[:count].zero?
    end

    # Returns whether there is a next page.
    #
    # @return [Boolean]
    def next?
      !empty? && @pages[:current] < @pages[:count]
    end

    # Returns whether there is a previous page.
    #
    # @return [Boolean]
    def previous?
      !empty? && @pages[:current] > 1
    end

    # Returns the number of the current page.
    #
    # @return [Fixnum]
    def current_page
      @pages[:current]
    end

    # Creates a list with the items.
    #
    # @return [MdnQuery::List]
    def to_list
      items = @items.map do |i|
        MdnQuery::Entry.new(i[:title], i[:excerpt], i[:url])
      end
      MdnQuery::List.new(query, *items)
    end
  end
end
