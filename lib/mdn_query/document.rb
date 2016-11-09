module MdnQuery
  # A document of an entry of the Mozilla Developer Network documentation.
  class Document
    # @return [String]
    attr_reader :title, :url

    # @return [MdnQuery::Section] the top level section
    attr_reader :section

    # Creates a document filled with the content of the URL.
    #
    # @param url [String] the URL to the document on the web
    # @return [MdnQuery::Document]
    def self.from_url(url)
      begin
        response = RestClient::Request.execute(method: :get, url: url,
                                               headers: { accept: 'text/html' })
      rescue RestClient::Exception, SocketError => e
        raise MdnQuery::HttpRequestFailed.new(url, e),
              'Could not retrieve entry'
      end
      dom = Nokogiri::HTML(response.body)
      title = dom.css('h1').text
      article = dom.css('article')
      document = new(title, url)
      MdnQuery::TraverseDom.fill_document(article, document)
      document
    end

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
