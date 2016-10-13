module MdnQuery
  # A result from a query of an MDN docs entry
  class EntryResult < MdnQuery::Result
    attr_reader :sections

    def initialize(response)
      super(response)
      article = response.dom.css('article')
      @sections = MdnQuery::TraverseDom.extract_sections(article)
    end
  end
end