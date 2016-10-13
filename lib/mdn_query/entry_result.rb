module MdnQuery
  # A result from a query of an MDN docs entry
  class EntryResult < MdnQuery::Result
    def initialize(response)
      super(response)
    end
  end
end
