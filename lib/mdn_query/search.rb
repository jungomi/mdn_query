module MdnQuery
  # A search request to the Mozilla Developer Network documentation.
  class Search
    # @return [String] a search option (see {#initialize})
    attr_accessor :css_classnames, :locale, :highlight, :html_attributes,
                  :query, :result, :topics

    # rubocop:disable Metrics/LineLength

    # Creates a new search.
    #
    # The search request is not automatically executed (use {#execute}).
    #
    # @param query [String] the query to search for
    # @param options [Hash] the search query options (more informations on
    #   {https://developer.mozilla.org/en-US/docs/MDN/Contribute/Tools/Search#Search_query_format})
    # @option options :css_classnames [String] the CSS classes to match
    # @option options :highlight [Boolean] whether the query is highlighted
    # @option options :html_attributes [String] the HTML attribute text to match
    # @option options :locale [String] the locale to match against
    # @option options :topics [Array<String>] the topics to search in
    # @return [MdnQuery::Search]
    def initialize(query, options = {})
      @url = "#{MdnQuery::BASE_URL}.json"
      @query = query
      @css_classnames = options[:css_classnames]
      @locale = options[:locale] || 'en-US'
      @highlight = options[:highlight] || false
      @html_attributes = options[:html_attributes]
      @topics = options[:topics] || ['js']
      @result = nil
    end
    # rubocop:enable Metrics/LineLength

    # Creates the URL used for the request.
    #
    # @return [String] the full URL
    def url
      query_url = "#{@url}?q=#{@query}&locale=#{@locale}"
      query_url << @topics.map { |t| "&topic=#{t}" }.join
      unless @css_classnames.nil?
        query_url << "&css_classnames=#{@css_classnames}"
      end
      unless @html_attributes.nil?
        query_url << "&html_attributes=#{@html_attributes}"
      end
      query_url << "&highlight=#{@highlight}" unless @highlight.nil?
      query_url
    end

    # Executes the search request.
    #
    # @return [MdnQuery::SearchResult] the search result
    def execute
      @result = MdnQuery::SearchResult.from_url(url)
    end

    # Fetches the next page of the search result.
    #
    # If there is no search result yet, {#execute} will be called instead.
    #
    # @return [MdnQuery::SearchResult] if a new result has been acquired
    # @return [nil] if there is no next page
    def next_page
      if @result.nil?
        execute
      elsif @result.next?
        query_url = url
        query_url << "&page=#{@result.current_page + 1}"
        @result = MdnQuery::SearchResult.from_url(query_url)
      end
    end

    # Fetches the previous page of the search result.
    #
    # If there is no search result yet, {#execute} will be called instead.
    #
    # @return [MdnQuery::SearchResult] if a new result has been acquired
    # @return [nil] if there is no previous page
    def previous_page
      if @result.nil?
        execute
      elsif @result.previous?
        query_url = url
        query_url << "&page=#{@result.current_page - 1}"
        @result = MdnQuery::SearchResult.from_url(query_url)
      end
    end

    # Opens the search in the default web browser.
    #
    # @return [void]
    def open
      html_url = url.sub('.json?', '?')
      Launchy.open(html_url)
    end
  end
end
