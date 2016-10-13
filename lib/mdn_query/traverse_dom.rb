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
        when 'pre'
          @current.append_code(child.text)
        when /\Ah(?<level>\d)\z/
          create_child($LAST_MATCH_INFO[:level].to_i, child[:id])
        end
      end
    end
  end
end
