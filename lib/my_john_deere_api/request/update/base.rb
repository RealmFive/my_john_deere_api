require 'json'

module MyJohnDeereApi::Request
  class Update::Base
    attr_reader :accessor, :item, :attributes, :errors, :response

    ##
    # Accepts a valid oAuth AccessToken, the item to be updated, 
    # and a hash of attributes.
    #
    # category/type/subtype must be a recognized combination as defined above.

    def initialize(accessor, item, attributes)
      @accessor = accessor
      @item = item
      @attributes = attributes

      process_attributes

      @errors = {}
    end

    ##
    # Make the request, if the instance is valid

    # def request
    #   validate!
    #
    #   @response = accessor.post(resource, request_body.to_json, headers)
    # end

    ##
    # Object created by request

    # def object
    #   return @object if defined?(@object)
    #
    #   request unless response
    #
    #   @object = model.new(fetch_record, accessor)
    # end

    ##
    # Runs validations, adding to the errors hash as needed. Returns true
    # if the errors hash is still empty after all validations have been run.

    # def valid?
    #   return @is_valid if defined?(@is_valid)
    #
    #   validate_required
    #   validate_attributes
    #
    #   @is_valid = errors.empty?
    # end

    ##
    # Raises an error if the record is invalid. Passes the errors hash
    # to the error, in order to build a useful message string.

    # def validate!
    #   raise(InvalidRecordError, errors) unless valid?
    # end

    private

    ##
    # Run validations unique to a given model. This should be overridden
    # by children where needed.

    # def validate_attributes
    # end

    ##
    # Convert inputs into working attributes. This allows us to auto-create
    # some attributes from others, or set defaults, on a class-by-class basis.
    # See Request::Create::AssetLocation for an example.

    def process_attributes
    end

    ##
    # Attributes that must be specified, override in child class

    def required_attributes
      []
    end

    ##
    # Validates required attributes

    def validate_required
      required_attributes.each do |attr|
        errors[attr] = 'is required' unless attributes[attr]
      end
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