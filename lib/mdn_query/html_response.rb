module MdnQuery
  # A HTML response
  class HtmlResponse < MdnQuery::Response
    def initialize(headers, code, body)
      super(headers, code, body)
    end
  end
end
