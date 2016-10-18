module MdnQuery
  # The standard error.
  class Error < StandardError; end

  # The error when no entries were found.
  class NoEntryFound < MdnQuery::Error
    # @return [String] the query that was searched for
    attr_reader :query

    # @return [Hash] the options used for the search
    attr_reader :options

    # Creates a new NoEntryFound error.
    #
    # @param query [String] the query that was searched for
    # @param options [Hash] the options used for the search
    # @return [MdnQuery::NoEntryFound]
    def initialize(query, options = {})
      @query = query
      @options = options
    end
  end

  # The error for failed HTTP request of any kind.
  class HttpRequestFailed < MdnQuery::Error
    # @return [String] the URL of the request
    attr_reader :url

    # @return [SocketError, RestClient::Exception] the original error
    attr_reader :http_error

    # Creates a new HttpRequestFailed error.
    #
    # @param url [String] the URL of the request
    # @param error [SocketError, RestClient::Exception] the original error
    # @return [MdnQuery::HttpRequestFailed]
    def initialize(url, error)
      @url = url
      @http_error = error
    end
  end
end
