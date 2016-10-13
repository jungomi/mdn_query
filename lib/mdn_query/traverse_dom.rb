module MdnQuery
  # Traverses the DOM and creates sections
  class TraverseDom
    attr_reader :current, :sections
    attr_accessor :dom

    def self.extract_sections(dom)
      traverser = new(dom)
      traverser.traverse
      traverser.sections
    end

    def self.traverse(dom)
      traverser = new(dom)
      traverser.traverse
      traverser
    end

    def initialize(dom)
      @dom = dom
      @sections = []
      @current = MdnQuery::Section.new('article')
      @sections << current
    end

    def create_child(desired_level, name)
      until @current.level < desired_level || @current.parent.nil?
        @current = @current.parent
      end
      @current = @current.create_child(name)
    end

    def traverse
      @dom.children.each do |child|
        case child.name
        when 'p'
          @current.append_text(child.text)
        when 'ul'
          append_list(child)
        when 'dl'
          append_definition(child)
        when 'pre'
          @current.append_code(child.text, language: 'javascript')
        when /\Ah(?<level>\d)\z/
          create_child($LAST_MATCH_INFO[:level].to_i, child[:id].tr('_', ' '))
        end
      end
    end

    private

    def append_list(ul)
      lines = ul.children.map do |child|
        if child.name == 'li'
          "- #{child.text}"
        else
          child.text
        end
      end
      @current.append_text(lines.join)
    end

    def append_definition(dl)
      lines = dl.children.map do |child|
        if child.name == 'dt'
          "\n**#{child.text}**\n"
        else
          child.text
        end
      end
      @current.append_text(lines.join)
    end
  end
end
