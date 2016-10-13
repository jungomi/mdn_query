module MdnQuery
  # A JSON response
  class JsonResponse < MdnQuery::Response
    def initialize(headers, code, body)
      super(headers, code, body)
    end

    def to_h
      JSON.parse(@body, symbolize_names: true)
    end
  end
end
