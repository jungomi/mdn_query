module MdnQuery
  # A HTTP response
  class Response
    attr_reader :code, :headers

    def initialize(headers, code)
      @headers = headers
      @code = code
    end
  end
end
