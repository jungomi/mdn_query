# MdnQuery

[![Gem Version][gem-badge]][gem]
[![Build Status][travis-img]][travis]
[![Code Climate][codeclimate-badge]][codeclimate]
[![Test Coverage][coverage-badge]][coverage]

Query the [Mozilla Developer Network][mdn] documentation. Unfortunately they do
not provide an API to fetch the documentation entries, which means that all
informations are extracted from the HTML pages to create a Markdown-like
representation. Another drawback is that it requires two network requests to
retrieve a single entry based on a search term, which is frequently desired as
a precise search term almost always yields the concrete entry as the first
result.

[Documentation][docs]

## CLI

The binary `mdn-query` provides an interactive command line interface to easily
search a query. By default it only searches for results in the JavaScript topic.

```
Usage: mdn-query [options] <search-term>

Options:
    -v, --version               Shows the program's version
    -h, --help                  Shows this help message
    -f, --first, --first-match  Returns the first match instead of a list
    -o, --open, --open-browser  Opens the appropriate page in the default web browser
    -t, --topics                The topics to search in, delimited by commas
```

### Examples

```sh
mdn-query bind                  # Searches for 'bind'
mdn-query bind --first          # Retrieves first match of the search result
mdn-query bind --open           # Opens the search results in the default browser
mdn-query bind --first --open   # Opens the first match in the default browser
mdn-query bind --topics js,css  # Searches in the topics 'js' and 'css'
```

### Demo

![Demo][demo]

## Library

### Top level methods

The following methods, that each take the search query and optional search
options as parameters, cover the most common use cases:

#### MdnQuery.list(query, options)

Creates a list with the search results. The entries in the list do not yet
contain the content of the corresponding documentation entries. They need to be
fetched individually.

```ruby
list = MdnQuery.list('bind')
# Searches in the topics 'js' and 'css'
list = MdnQuery.list('bind', topics: ['js', 'css'])
# Prints a numbered list of the search result with a small description
puts list
# Finds all items that include 'Object' in their title
object_entries = list.items.select { |e| e.title =~ /Object/ }
```

#### MdnQuery.first_match(query, options)

Retrieves the content of the first entry of the search results. This requires
two network requests, because it is required to first search the Mozilla
Developer Network and then fetch the page of the respective entry.

```ruby
content = MdnQuery.first_match('bind')
# Prints a Markdown-like representation of the entry
puts content
```

#### MdnQuery.open_list(query, options)

Opens the search query in the default web browser instead of retrieving the
results, therefore there is no network request made.

```ruby
MdnQuery.open_list('bind')
```

#### MdnQuery.open_first_match(query, options)

Opens the first entry in the default web browser instead of fetching the
corresponding page. This means there is only one network request to retrieve the
list of search results.

```ruby
MdnQuery.open_first_match('bind')
```

### Search

```ruby
# Creates a new search that is not executed yet
search = MdnQuery::Search.new('bind', topics: ['js', 'css'])
# Opens the search results in the default web browser
search.open
# Executes the search request
search.execute
# Creates a list of the search results
list = search.result.to_list
```

A search result can contain multiple pages. To easily navigate through the
pages, the methods `next_page` and `previous_page` are available, that retrieve
the next and previous page respectively, if it exists.

```ruby
# Retrieves the next page of the search results
search.next_page
# Retrieves the previous page of the search results
search.previous_page
```

### Entry

The content of an entry can be retrieved with the method `content`, which
fetches the documentation entry once, and simply returns it on further calls.

```ruby
list = MdnQuery.list('bind', topics: ['js', 'css'])
entry = list.first
# Opens the entry in the default web browser
entry.open
# Prints the entry's content, performing a network request
puts entry.content
# Prints the content again without another network request
puts entry.content
```

## Contributing

Bug reports and pull requests are welcome on [GitHub][github-repo].

## License

The gem is available as open source under the terms of the [MIT License][mit].

[codeclimate]: https://codeclimate.com/github/jungomi/mdn_query
[codeclimate-badge]: https://codeclimate.com/github/jungomi/mdn_query/badges/gpa.svg
[coverage]: https://codeclimate.com/github/jungomi/mdn_query/coverage
[coverage-badge]: https://codeclimate.com/github/jungomi/mdn_query/badges/coverage.svg
[demo]: screenshots/demo.gif
[docs]: http://www.rubydoc.info/gems/mdn_query
[gem]: https://badge.fury.io/rb/mdn_query
[gem-badge]: https://badge.fury.io/rb/mdn_query.svg
[github-repo]: https://github.com/jungomi/mdn-query
[mdn]: https://developer.mozilla.org/en-US/docs/Web/JavaScript
[mit]: http://opensource.org/licenses/MIT
[travis]:  https://travis-ci.org/jungomi/mdn_query
[travis-img]: https://travis-ci.org/jungomi/mdn_query.svg?branch=master
