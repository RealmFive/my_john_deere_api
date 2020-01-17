require 'json'

module MyJohnDeereApi
  class Request::Create::Asset < Request::Create::Base
    attr_reader :accessor, :attributes, :errors, :response

    REQUIRED_ATTRIBUTES = [:organization_id, :contribution_definition_id, :title]

    VALID_CATEGORIES = {
      'DEVICE' => {
        'SENSOR' => ['GRAIN_BIN', 'ENVIRONMENTAL', 'IRRIGATION_PIVOT', 'OTHER']
      },

      'EQUIPMENT' => {
        'MACHINE' => ['PICKUP_TRUCK', 'UTILITY_VEHICLE'],
        'OTHER' => ['ANHYDROUS_AMMONIA_TANK', 'NURSE_TRUCK', 'NURSE_WAGON', 'TECHNICIAN_TRUCK']
      },
    }

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
    # Object created by request

    def object
      return @object if defined?(@object)

      request unless response

      object_id = response['location'].split('/').last
      result = accessor.get("/assets/#{object_id}", headers)

      @object = Model::Asset.new(JSON.parse(result.body), accessor)
    end

    ##
    # Make the request, if the instance is valid

    def request
      validate!
      @response = accessor.post(resource, request_body.to_json, headers)
    end

    ##
    # Raises an error if the record is invalid. Passes the errors hash
    # to the error, in order to build a useful message string.

    def validate!
      raise(InvalidRecordError, errors) unless valid?
    end

    ##
    # Runs validations, adding to the errors hash as needed. Returns true
    # if the errors hash is still empty after all validations have been run.

    def valid?
      return @is_valid if defined?(@is_valid)

      validate_required

      unless valid_categories?(attributes[:asset_category], attributes[:asset_type], attributes[:asset_sub_type])
        errors[:asset_category] = 'requires valid combination of category/type/subtype'
      end

      @is_valid = errors.empty?
    end

    private

    ##
    # Path supplied to API

    def resource
      @path ||= "/organizations/#{attributes[:organization_id]}/assets"
    end

    ##
    # Request body

    def request_body
      return @body if defined?(@body)


      @body = {
        title: attributes[:title],
        assetCategory: attributes[:asset_category],
        assetType: attributes[:asset_type],
        assetSubType: attributes[:asset_sub_type],
        links: [
          {
            '@type' => 'Link',
            'rel' => 'contributionDefinition',
            'uri' => "#{accessor.consumer.site}/contributionDefinitions/#{attributes[:contribution_definition_id]}"
          }
        ]
      }
    end

    ##
    # Validates required attributes

    def validate_required
      REQUIRED_ATTRIBUTES.each do |attr|
        errors[attr] = 'is required' unless attributes.keys.include?(attr)
      end
    end

    ##
    # Returns boolean, true if this combination is valid

    def valid_categories?(category, type, subtype)
      VALID_CATEGORIES.dig(category, type).to_a.include?(subtype)
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