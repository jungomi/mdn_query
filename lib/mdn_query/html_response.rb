module MdnQuery
  # A HTML response
  class HtmlResponse < MdnQuery::Response
    attr_reader :dom

    def initialize(headers, code, body)
      super(headers, code, body)
      @dom = Nokogiri::HTML(body)
    end
  end
end
