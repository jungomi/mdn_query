require 'English'
require 'nokogiri'
require 'launchy'
require 'rest-client'

require 'mdn_query/document'
require 'mdn_query/entry'
require 'mdn_query/errors'
require 'mdn_query/list'
require 'mdn_query/search_result'
require 'mdn_query/search'
require 'mdn_query/section'
require 'mdn_query/table'
require 'mdn_query/traverse_dom'
require 'mdn_query/version'

# Query the MDN docs
module MdnQuery
  BASE_URL = 'https://developer.mozilla.org/search'.freeze

  def self.list(query, options = {})
    search = MdnQuery::Search.new(query, options)
    list = search.execute.to_list
    if list.empty?
      raise MdnQuery::NoEntryFound.new(query, options), 'No entry found'
    end
  end

  def self.first_match(query, options = {})
    entry = list(query, options).first
    entry.content
  end
end
