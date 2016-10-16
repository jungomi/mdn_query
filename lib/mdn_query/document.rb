module MdnQuery
  # A document of the MDN docs
  class Document
    attr_reader :title, :url, :section

    def initialize(title, url = nil)
      @title = title
      @url = url
      @section = MdnQuery::Section.new(title)
    end

    def open
      Launchy.open(@url) unless @url.nil?
    end

    def to_s
      @section.to_s
    end
    alias to_md to_s
  end
end
