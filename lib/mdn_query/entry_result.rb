module MdnQuery
  # A result from a query of an MDN docs entry
  class EntryResult < MdnQuery::Result
    attr_reader :document

    def initialize(response)
      super(response)
      title = response.dom.css('h1').text
      article = response.dom.css('article')
      @document = MdnQuery::TraverseDom.extract_document(article, name: title)
    end

    def to_s
      @document.to_s
    end
  end
end
