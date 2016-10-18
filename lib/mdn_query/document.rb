module MdnQuery
  # A document of an entry of the Mozilla Developer Network documentation.
  class Document
    # @return [String]
    attr_reader :title, :url

    # @return [MdnQuery::Section] the top level section
    attr_reader :section

    # Creates a new document with an initial top level section.
    #
    # @param title [String] the titel of the top level section
    # @param url [String] the URL to the document on the web
    # @return [MdnQuery::Document]
    def initialize(title, url = nil)
      @title = title
      @url = url
      @section = MdnQuery::Section.new(title)
    end

    # Opens the document in the default web browser if a URL has been specified.
    #
    # @return [void]
    def open
      Launchy.open(@url) unless @url.nil?
    end

    # Returns the string representation of the document.
    #
    # @return [String]
    def to_s
      @section.to_s
    end
    alias to_md to_s
  end
end
