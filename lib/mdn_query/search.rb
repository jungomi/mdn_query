module MdnQuery
  # A search request to the MDN docs
  class Search
    attr_accessor :css_classnames, :locale, :highlight, :html_attributes,
                  :query, :result, :topic

    def initialize(query, options = {})
      @url = MdnQuery::Query.base_url
      @url << '.json'
      @query = query
      @css_classnames = options[:css_classnames]
      @locale = options[:locale] || 'enUS'
      @highlight = options[:highlight] || false
      @html_attributes = options[:html_attributes]
      @topic = options[:topic] || 'js'
    end

    def url
      query_url = "#{@url}?q=#{@query}&locale=#{@locale}&topic=#{@topic}"
      unless @css_classnames.nil?
        query_url << "&css_classnames#{@css_classnames}"
      end
      unless @html_attributes.nil?
        query_url << "&html_attributes=#{@html_attributes}"
      end
      query_url << "&highlight=#{@highlight}" unless @highlight.nil?

      query_url
    end

    def execute
      @result = retrieve(url, @query)
    end

    def next
      if @result.nil?
        execute
      elsif @result.next?
        query_url = url
        query_url << "&page=#{@result.current_page + 1}"
        @result = retrieve(query_url, @query)
      end
    end

    def previous
      if @result.nil?
        execute
      elsif @result.previous?
        query_url = url
        query_url << "&page=#{@result.current_page - 1}"
        @result = retrieve(query_url, @query)
      end
    end

    private

    def retrieve(url, query)
      response = RestClient::Request.execute(method: :get, url: url,
                                             headers: { accept: 'json' })
      response = MdnQuery::JsonResponse.new(response.headers, response.code,
                                            response.body)
      MdnQuery::SearchResult.new(response, query)
    end
  end
end
