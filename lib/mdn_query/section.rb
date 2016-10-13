module MdnQuery
  # A section of an entry of the MDN docs
  class Section
    attr_reader :children, :name, :level, :parent, :text

    def initialize(name, level: 1, parent: nil)
      @name = name
      @level = level
      @parent = parent
      @text = []
      @children = []
    end

    def create_child(name)
      child = MdnQuery::Section.new(name, parent: self, level: @level + 1)
      @children << child
      child
    end

    def append_text(text)
      @text << text
    end

    def append_code(snippet)
      @text << "\n```javascript\n#{snippet}\n```\n"
    end

    def to_s
      "#{'#' * level} #{name}\n\n#{join_text}\n\n#{join_children}"
    end

    private

    def join_text
      text.join("\n")
    end

    def join_children
      children.map(&:to_s).join("\n")
    end
  end
end