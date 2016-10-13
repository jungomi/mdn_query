module MdnQuery
  # Traverses the DOM and creates sections
  class TraverseDom
    attr_reader :current, :sections
    attr_accessor :dom

    BLACKLIST = %w(Specifications Browser_compatibility).freeze

    def self.extract_sections(dom, name: 'root')
      traverser = new(dom, name: name)
      traverser.traverse
      traverser.sections
    end

    def self.traverse(dom, name: 'root')
      traverser = new(dom, name: name)
      traverser.traverse
      traverser
    end

    def initialize(dom, name: 'root')
      @dom = dom
      @sections = []
      @current = MdnQuery::Section.new(name)
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
          @current.append_text(convert_list(child))
        when 'dl'
          @current.append_text(convert_description(child))
        when 'pre'
          @current.append_code(child.text, language: 'javascript')
        when /\Ah(?<level>\d)\z/
          next if blacklisted?(child[:id])
          create_child($LAST_MATCH_INFO[:level].to_i, child[:id].tr('_', ' '))
        end
      end
    end

    def blacklisted?(id)
      BLACKLIST.include?(id)
    end

    private

    def convert_list(ul)
      lines = ul.children.map do |child|
        if child.name == 'ul'
          convert_list(child)
        elsif child.name == 'li'
          "- #{child.text}"
        else
          child.text
        end
      end
      lines.join
    end

    def convert_description(dl)
      lines = dl.children.map do |child|
        if child.name == 'dd' || child.name == 'dl'
          convert_description(child)
        elsif child.name == 'dt'
          "\n**#{child.text}**\n"
        else
          child.text
        end
      end
      lines.join
    end
  end
end
