require 'English'
require 'json'
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

# Query the Mozilla Developer Network documentation.
module MdnQuery
  # The base url for the search queries.
  BASE_URL = 'https://developer.mozilla.org/search'.freeze

  # Searches the given query and creates a list with the results.
  #
  # @param query [String] the query to search for
  # @param options [Hash] additional query options (see
  #   {MdnQuery::Search#initialize})
  # @raise [MdnQuery::HttpRequestFailed] if a HTTP request fails
  # @raise [MdnQuery::NoEntryFound] if no entry was found
  # @return [MdnQuery::List] the list of results
  def self.list(query, options = {})
    search = MdnQuery::Search.new(query, options)
    list = search.execute.to_list
    if list.empty?
      raise MdnQuery::NoEntryFound.new(query, options), 'No entry found'
    end
    list
  end

  # Searches the given query and returns the first fetched entry in the list.
  #
  # @param query [String] the query to search for
  # @param options [Hash] additional query options (see
  #   {MdnQuery::Search#initialize})
  # @raise [MdnQuery::HttpRequestFailed] if a HTTP request fails
  # @raise [MdnQuery::NoEntryFound] if no entry was found
  # @return [MdnQuery::Document] the document of entry
  def self.first_match(query, options = {})
    entry = list(query, options).first
    entry.content
  end

  # Searches the given query and opens the result in the default browser.
  #
  # @param query [String] the query to search for
  # @param options [Hash] additional query options (see
  #   {MdnQuery::Search#initialize})
  # @raise [MdnQuery::HttpRequestFailed] if a HTTP request fails
  # @raise [MdnQuery::NoEntryFound] if no entry was found
  # @return [void]
  def self.open_list(query, options = {})
    search = MdnQuery::Search.new(query, options)
    search.open
  end

  # Searches the given query and opens the first entry in the default browser.
  #
  # @param query [String] the query to search for
  # @param options [Hash] additional query options (see
  #   {MdnQuery::Search#initialize})
  # @raise [MdnQuery::HttpRequestFailed] if a HTTP request fails
  # @raise [MdnQuery::NoEntryFound] if no entry was found
  # @return [void]
  def self.open_first_match(query, options = {})
    entry = list(query, options).first
    entry.open
  end
end
