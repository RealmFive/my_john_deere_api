require 'json'

module MyJohnDeereApi
  class Request::Create::Base
    attr_reader :accessor, :attributes, :errors, :response

    ##
    # Accepts a valid oAuth AccessToken, and a hash of attributes.
    #
    # Required attributes:
    #  - organization_id
    #  - contribution_definition_id
    #  - title
    #  - asset_category
    #  - asset_type
    #  - asset_sub_type
    #
    # category/type/subtype must be a recognized combination as defined above.

    def initialize(accessor, attributes)
      @accessor = accessor
      @attributes = attributes

      @errors = {}
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

      @object = model.new(fetch_record, accessor)
    end

    ##
    # Runs validations, adding to the errors hash as needed. Returns true
    # if the errors hash is still empty after all validations have been run.

    def valid?
      return @is_valid if defined?(@is_valid)

      validate_required
      validate_attributes

      @is_valid = errors.empty?
    end

    ##
    # Run validations unique to a given model. This should be overridden
    # by children where needed.

    def validate_attributes
    end

    ##
    # Raises an error if the record is invalid. Passes the errors hash
    # to the error, in order to build a useful message string.

    def validate!
      raise(InvalidRecordError, errors) unless valid?
    end

    private

    ##
    # Attributes that must be specified, override in child class

    def required_attributes
      []
    end

    ##
    # Validates required attributes

    def validate_required
      required_attributes.each do |attr|
        errors[attr] = 'is required' unless attributes.keys.include?(attr)
      end
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