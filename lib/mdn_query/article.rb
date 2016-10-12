module MdnQuery
  # An MDN article
  class Article
    attr_reader :title, :description, :content

    def initialize(title, description, content = nil)
      @title = title
      @description = description
      @content = content
    end

    def content?
      !content.nil?
    end
  end
end
