module MdnQuery
  # A section of an entry of the Mozilla Developer Network documentation.
  class Section
    # @return [Array<MdnQuery::Section>] the list of child sections
    attr_reader :children

    # @return [String] the name and title of the section
    attr_reader :name

    # @return [Fixnum] the level of the section
    attr_reader :level

    # @return [MdnQuery::Section] the parent section
    attr_reader :parent

    # @return [Array<String>] the text segments of the section
    attr_reader :text

    # Creates a new section.
    #
    # @param name [String] the name and title of the section
    # @param level [Fixnum] the level of the section
    # @param parent [MdnQuery::Section] the parent section
    # @return [MdnQuery::Section]
    def initialize(name, level: 1, parent: nil)
      @name = name
      @level = level
      @parent = parent
      @text = []
      @children = []
    end

    # Creates a new child section.
    #
    # @param name [String] the name and title of the child section
    # @return [MdnQuery::Section] the new child section
    def create_child(name)
      child = MdnQuery::Section.new(name, parent: self, level: @level + 1)
      @children << child
      child
    end

    # Appends a text segment to the section.
    #
    # Spaces before and after newlines are removed. If the text segment is empty
    # (i.e. consists of just whitespaces), it is not appended.
    #
    # @param text [String] the text segment to append
    # @return [void]
    def append_text(text)
      trimmed_text = text.gsub(/\n[[:blank:]]+|[[:blank:]]+\n/, "\n")
      @text << trimmed_text unless text_empty?(trimmed_text)
    end

    # Appends a code segment to the section.
    #
    # If the code segment is empty (i.e. consists of just whitespaces), it is
    # not appended. The given snippet is embedded in a Markdown code block.
    #
    # @example Add a JavaScript snippet
    #   append_code("const name = 'My Name';", language: 'javascript')
    #   # adds the following text:
    #   # ```javascript
    #   # const name = 'My Name';
    #   # ```
    #
    # @param snippet [String] the code segment to append
    # @param language [String] the language of the code
    # @return [void]
    def append_code(snippet, language: '')
      @text << "\n```#{language}\n#{snippet}\n```\n" unless text_empty?(snippet)
    end

    # Returns the string representation of the section.
    #
    # @return [String]
    def to_s
      str = "#{'#' * level} #{name}\n\n#{join_text}\n\n#{join_children}\n"
      str.gsub!(/\n+[[:blank:]]+\n+|\n{3,}/, "\n\n")
      str.strip!
      str
    end

    private

    def join_text
      text.join("\n")
    end

    def join_children
      children.map(&:to_s).join("\n\n")
    end

    def text_empty?(text)
      !text.match(/\A\s*\z/).nil?
    end
  end
end
