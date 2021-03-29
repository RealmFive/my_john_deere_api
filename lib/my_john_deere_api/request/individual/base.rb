require 'json'

module MyJohnDeereApi::Request
  class Individual::Base
    attr_reader :client, :id, :associations

    ##
    # Initialize with a client, and asset id

    def initialize(client, id, associations = {})
      @client = client
      @id = id
      @associations = associations
    end

    ##
    # The object being requested, an asset in this case

    def object
      return @object if defined?(@object)
      @object = model.new(client, response)
    end

    private

    ##
    # response from object request

    def response
      return @response if defined?(@response)
      @response = client.get(resource)
    end
  end
end