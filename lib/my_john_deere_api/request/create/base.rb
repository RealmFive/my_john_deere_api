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
    # client accessor

    def accessor
      return @accessor if defined?(@accessor)
      @accessor = client&.accessor
    end

    ##
    # Make the request, if the instance is valid

    def request
      validate!

      @response = accessor.post(resource, request_body.to_json, headers)
    end

    ##
    # Object created by request

    def object
      return @object if defined?(@object)

      request unless response

      @object = model.new(client, fetch_record)
    end

    private

    ##
    # Convert inputs into working attributes. This allows us to auto-create
    # some attributes from others, or set defaults, on a class-by-class basis.
    # See Request::Create::AssetLocation for an example.

    def process_attributes
    end

    ##
    # Headers for POST request

    def headers
      @headers ||= {
        'Accept'        => 'application/vnd.deere.axiom.v3+json',
        'Content-Type'  => 'application/vnd.deere.axiom.v3+json'
      }
    end
  end
end