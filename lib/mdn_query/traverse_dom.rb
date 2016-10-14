module MdnQuery
  # Traverses the DOM and creates a document
  class TraverseDom
    attr_reader :current, :dom, :document

    BLACKLIST = %w(Specifications Browser_compatibility).freeze

    def self.extract_document(dom, name: 'root')
      traverser = new(dom, name: name)
      traverser.traverse
      traverser.document
    end

    def self.traverse(dom, name: 'root')
      traverser = new(dom, name: name)
      traverser.traverse
      traverser
    end

    def initialize(dom, name: 'root')
      @dom = dom
      @current = MdnQuery::Section.new(name)
      @document = @current
    end

    def create_child(desired_level, name)
      until @current.level < desired_level || @current.parent.nil?
        @current = @current.parent
      end
      @current = @current.create_child(name)
    end

    def traverse
      unless @dom.css('div.nonStandard').nil?
        @current.append_text("\n> ***Non-standard***\n")
      end
      within_blacklist = false
      @dom.children.each do |child|
        next if within_blacklist && child.name.match(/\Ah\d\z/).nil?
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
          within_blacklist = blacklisted?(child[:id])
          next if within_blacklist
          create_child($LAST_MATCH_INFO[:level].to_i, child[:id].tr('_', ' '))
        when 'table'
          @current.append_text(convert_table(child))
        when 'div'
          next if child[:class].nil?
          if child[:class].include?('note') || child[:class].include?('warning')
            @current.append_text("\n> #{child.text}\n")
          end
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

    def convert_table(table)
      body = table.css('tbody > tr').map { |tr| extract_table_row(tr) }
      head_row = table.css('thead > tr').first
      head = if head_row.nil?
               # Make first row in body the table heading
               body.shift
             else
               extract_table_row(head_row)
             end
      table = MdnQuery::Table.new(head, *body)
      table.to_s
    end

    def extract_table_row(tr)
      cols = []
      tr.children.each do |child|
        next unless child.name == 'th' || child.name == 'td'
        cols << child.text
      end
      cols
    end
  end
end
