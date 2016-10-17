module MdnQuery
  # The standard error
  class Error < StandardError; end

  # The error when no entries where found
  class NoEntryFound < MdnQuery::Error
    attr_reader :query, :options

    def initialize(query, options = {})
      @query = query
      @options = options
    end
  end

  # The error for failed HTTP request of any kind
  class HttpRequestFailed < MdnQuery::Error
    attr_reader :url, :http_error

    def initialize(url, error)
      @url = url
      @http_error = error
    end
  end
end
