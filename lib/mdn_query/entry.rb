module MdnQuery
  # An entry of the Mozilla Developer Network documentation.
  class Entry
    # @return [String]
    attr_reader :title, :description, :url

    # Creates a new entry.
    #
    # @param title [String] the title of the entry
    # @param description [String] a small excerpt of the entry
    # @param url [String] the URL to the entry on the web
    # @return [MdnQuery::Entry]
    def initialize(title, description, url)
      @title = title
      @description = description
      @url = url
      @content = nil
    end

    # Returns the string representation of the entry.
    #
    # @return [String]
    def to_s
      "#{title}\n#{description}\n#{url}"
    end

    # Opens the entry in the default web browser.
    #
    # @return [void]
    def open
      Launchy.open(@url)
    end

    # Returns the content of the entry.
    #
    # The content is fetched from the Mozilla Developer Network's documentation.
    # The fetch occurs only once and subsequent calls return the previously
    # fetched content.
    #
    # @raise [MdnQuery::HttpRequestFailed] if a HTTP request fails
    # @return [MdnQuery::Document] the content of the entry
    def content
      return @content unless @content.nil?
      @content = MdnQuery::Document.from_url(url)
    end
  end
end
