require 'json'

module MyJohnDeereApi
  class Request::Update::Base
    include Validators::Base

    attr_reader :accessor, :item, :attributes, :response

    ##
    # Accepts a valid oAuth AccessToken, the item to be updated, 
    # and a hash of attributes.
    #
    # category/type/subtype must be a recognized combination as defined above.

    def initialize(accessor, item, attributes)
      @accessor = accessor
      @item = item
      @attributes = item.attributes.merge(attributes)

      process_attributes
    end

    ##
    # Make the request, if the instance is valid

    def request
      validate!

      @response = accessor.put(resource, request_body.to_json, headers)
    end

    ##
    # Object, same as item for updates

    def object
      @object ||= item
    end

    private

    ##
    # Convert inputs into working attributes. This allows us to auto-create
    # some attributes from others, or set defaults, on a class-by-class basis.
    # See Request::Create::AssetLocation for an example.

    def process_attributes
    end

    ##
    # Headers for PUT request

    def headers
      @headers ||= {
        'Accept'        => 'application/vnd.deere.axiom.v3+json',
        'Content-Type'  => 'application/vnd.deere.axiom.v3+json'
      }
    end
  end
end