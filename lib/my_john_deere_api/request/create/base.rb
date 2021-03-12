require 'json'

module MyJohnDeereApi
  class Request::Create::Base
    include Validators::Base

    attr_reader :client, :attributes, :response

    ##
    # Accepts a valid oAuth AccessToken, and a hash of attributes.

    def initialize(client, attributes)
      @client = client
      @attributes = attributes

      process_attributes
    end

    ##
    # Make the request, if the instance is valid

    def request
      validate!

      @response = client.post(resource, request_body)
    end

    ##
    # Object created by request

    def object
      return @object if defined?(@object)

      request unless response

      @object = individual_class.new(client, record_id).object
    end

    private

    ##
    # Convert inputs into working attributes. This allows us to auto-create
    # some attributes from others, or set defaults, on a class-by-class basis.
    # See Request::Create::AssetLocation for an example.

    def process_attributes
    end
  end
end