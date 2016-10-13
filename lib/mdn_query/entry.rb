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
  end
end
