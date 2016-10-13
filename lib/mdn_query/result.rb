module MdnQuery
  # A result from a query
  class Result
    attr_reader :response

    def initialize(response)
      @response = response
    end
  end
end
