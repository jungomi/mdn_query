module MdnQuery
  # A HTTP response
  class Response
    attr_reader :body, :code, :headers

    def initialize(headers, code, body)
      @headers = headers
      @code = code
      @body = body
    end

    def to_s
      @body.to_s
    end
  end
end
