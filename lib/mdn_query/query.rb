module MdnQuery
  # Query utilities
  module Query
    def self.base_url
      'https://developer.mozilla.org/search'
    end

    def self.list(query, options = {})
      search = MdnQuery::Search.new(query, options)
      search.execute.to_list
    end

    def self.first_match(query, options = {})
      item = list(query, options).first
      item.content.sections
    end
  end
end
