module MdnQuery
  # A JSON response
  class JsonResponse < MdnQuery::Response
    def initialize(headers, code, body)
      super(headers, code)
      @body = body
    end

    def to_h
      JSON.parse(@body, symbolize_names: true)
    end

    def to_s
      @body.to_s
    end
  end
end
