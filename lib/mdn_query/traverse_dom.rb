module MdnQuery
  # Traverses the DOM and creates a document
  class TraverseDom
    attr_reader :current, :dom, :document

    BLACKLIST = %w(Specifications Browser_compatibility).freeze

    def self.create_document(dom, title, url)
      document = MdnQuery::Document.new(title, url)
      fill_document(dom, document)
    end

    def self.fill_document(dom, document)
      traverser = new(dom, document: document)
      traverser.traverse
      traverser.document
    end

    def initialize(dom, document: nil, url: nil)
      @dom = dom
      @document = document || MdnQuery::Document.new('root', url)
      @current_section = @document.section
    end

    def create_child(desired_level, name)
      until @current_section.level < desired_level ||
            @current_section.parent.nil?
        @current_section = @current_section.parent
      end
      @current_section = @current_section.create_child(name)
    end

    def traverse
      unless @dom.css('div.nonStandard').nil?
        @current_section.append_text("\n> ***Non-standard***\n")
      end
      within_blacklist = false
      @dom.children.each do |child|
        next if within_blacklist && child.name.match(/\Ah\d\z/).nil?
        case child.name
        when 'p'
          @current_section.append_text(child.text)
        when 'ul'
          @current_section.append_text(convert_list(child))
        when 'dl'
          @current_section.append_text(convert_description(child))
        when 'pre'
          @current_section.append_code(child.text, language: 'javascript')
        when /\Ah(?<level>\d)\z/
          within_blacklist = blacklisted?(child[:id])
          next if within_blacklist
          create_child($LAST_MATCH_INFO[:level].to_i, child[:id].tr('_', ' '))
        when 'table'
          @current_section.append_text(convert_table(child))
        when 'div'
          next if child[:class].nil?
          if child[:class].include?('note') || child[:class].include?('warning')
            @current_section.append_text("\n> #{child.text}\n")
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
