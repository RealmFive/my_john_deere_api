require 'json'

module MyJohnDeereApi
  class Request::Update::Base
    include Validators::Base

    attr_reader :client, :item, :attributes, :response

    ##
    # Accepts a valid oAuth AccessToken, the item to be updated, 
    # and a hash of attributes.
    #
    # category/type/subtype must be a recognized combination as defined above.

    def initialize(client, item, attributes)
      @client = client
      @item = item
      @attributes = item.attributes.merge(attributes)

      process_attributes
    end

    ##
    # Make the request, if the instance is valid

    def request
      validate!

      @response = client.put(resource, request_body.to_json)
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
  end
end