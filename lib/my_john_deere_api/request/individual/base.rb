require 'json'

module MyJohnDeereApi::Request
  class Individual::Base
    attr_reader :client, :id, :associations, :response

    ##
    # Initialize with a client, and asset id

    def initialize(client, id, associations = {})
      @client = client
      @id = id
      @associations = associations
    end
    
    ##
    # client accessor
    
    def accessor
      return @accessor if defined?(@accessor)
      @accessor = client&.accessor
    end

    ##
    # The object being requested, an asset in this case

    def object
      return @object if defined?(@object)

      request unless response
      @object = model.new(JSON.parse(response.body), client)
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