module MdnQuery
  # A DOM traverser that extracts relevant elements.
  class TraverseDom
    # @return [MdnQuery::Section] the current section
    attr_reader :current_section

    # @return [Nokogiri::HTML::Document] the DOM that is traversed
    attr_reader :dom

    # @return [MdnQuery::Document] the document that contains the extracted text
    attr_reader :document

    # Sections that are blacklisted and excluded from the document.
    BLACKLIST = %w(Specifications Browser_compatibility).freeze

    # Creates a new document with the extracted text.
    #
    # @param dom [Nokogiri::HTML::Document] the DOM that is traversed
    # @param title [String] the title of the document
    # @param url [String] the URL to the document on the web
    # @return [MdnQuery::Document] the document with the extracted text
    def self.create_document(dom, title, url)
      document = MdnQuery::Document.new(title, url)
      fill_document(dom, document)
    end

    # Fills a document with the extracted text.
    #
    # @param dom [Nokogiri::HTML::Document] the DOM that is traversed
    # @param document [MdnQuery::Document] the document to be filled
    # @return [MdnQuery::Document] the document with the extracted text
    def self.fill_document(dom, document)
      traverser = new(dom, document: document)
      traverser.traverse
      traverser.document
    end

    # Creates a new DOM traverser.
    #
    # The given document is used to save the extracted text. If no document is
    # given, a new one is created with the generic title 'root' and the given
    # url.
    #
    # The DOM is not automatically traversed (use {#traverse}).
    #
    # @param dom [Nokogiri::HTML::Document] the DOM that is traversed
    # @param document [MdnQuery::Document] the document to be filled
    # @param url [String] the URL for the new document if none was provided
    # @return [MdnQuery::TraverseDom]
    def initialize(dom, document: nil, url: nil)
      @dom = dom
      @document = document || MdnQuery::Document.new('root', url)
      @current_section = @document.section
    end

    # Creates a new child section on the appropriate parent section.
    #
    # @param desired_level [Fixnum] the desired level for the child section
    # @param name [String] the name and title of the child section
    # @return [MdnQuery::Section] the newly created child section
    def create_child(desired_level, name)
      until @current_section.level < desired_level ||
            @current_section.parent.nil?
        @current_section = @current_section.parent
      end
      @current_section = @current_section.create_child(name)
    end

    # Traverses the DOM and extracts relevant informations into the document.
    #
    # @return [void]
    def traverse
      unless @dom.css('div.nonStandard').empty?
        @current_section.append_text("\n> ***Non-standard***\n")
      end
      blacklist_level = nil
      @dom.children.each do |child|
        if child_blacklisted?(child, blacklist_level)
          if blacklist_level.nil?
            blacklist_level = child.name.match(/\Ah(?<level>\d)\z/)[:level]
          end
          next
        end
        blacklist_level = nil
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
          level = $LAST_MATCH_INFO[:level].to_i
          create_child(level, child[:id].tr('_', ' '))
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

    # Returns whether the id is blacklisted.
    #
    # @param id [String] the id to be tested
    # @return [Boolean]
    def blacklisted?(id)
      BLACKLIST.include?(id)
    end

    private

    def child_blacklisted?(child, blacklist_level)
      match = child.name.match(/\Ah(?<level>\d)\z/)
      if match.nil?
        !blacklist_level.nil?
      else
        blacklisted?(child[:id]) ||
          (!blacklist_level.nil? && match[:level] > blacklist_level)
      end
    end

    def convert_list(ul)
      lines = ul.children.map do |child|
        if child.name == 'ul'
          convert_list(child)
        elsif child.name == 'li'
          "- #{child.text}\n"
        else
          child.text
        end
      end
      lines.join
    end

    def convert_description(dl)
      lines = dl.children.map do |child|
        if child.name == 'dl'
          convert_description(child)
        elsif child.name == 'dt'
          "\n**#{child.text}**\n"
        else
          "\n#{child.text}\n"
        end
      end
      # "#{lines.join}\n"
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
