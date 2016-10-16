module MdnQuery
  # An entry in the MDN docs
  class Entry
    attr_reader :title, :description, :url

    def initialize(title, description, url)
      @title = title
      @description = description
      @url = url
    end

    def to_s
      "#{title}\n#{description}\n#{url}"
    end

    def open
      Launchy.open(@url)
    end

    def content
      return @content unless @content.nil?
      @content = retrieve(url)
    end

    private

    def retrieve(url)
      response = RestClient::Request.execute(method: :get, url: url,
                                             headers: { accept: 'text/html' })
      dom = Nokogiri::HTML(response.body)
      title = dom.css('h1').text
      article = dom.css('article')
      MdnQuery::TraverseDom.extract_document(article, name: title)
    end
  end
end
