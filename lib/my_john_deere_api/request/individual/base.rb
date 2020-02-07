require 'json'

module MyJohnDeereApi::Request
  class Individual::Base
    attr_reader :accessor, :id, :associations, :response

    ##
    # Initialize with an accessor, and asset id

    def initialize(accessor, id, associations = {})
      @accessor = accessor
      @id = id
      @associations = associations
    end

    ##
    # The object being requested, an asset in this case

    def object
      return @object if defined?(@object)

      request unless response
      @object = model.new(JSON.parse(response.body), accessor)
    end

    private

    ##
    # Make the request

    def request
      @response = accessor.get(resource, headers)
    end

    ##
    # Headers for GET request

    def headers
      @headers ||= {
        'Accept'        => 'application/vnd.deere.axiom.v3+json',
      }
    end
  end
end