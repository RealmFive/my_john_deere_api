require 'json'

module MyJohnDeereApi
  class Request::Create::Asset < Request::Create::Base
    VALID_CATEGORIES = {
      'DEVICE' => {
        'SENSOR' => ['GRAIN_BIN', 'ENVIRONMENTAL', 'IRRIGATION_PIVOT', 'OTHER']
      },

      'EQUIPMENT' => {
        'MACHINE' => ['PICKUP_TRUCK', 'UTILITY_VEHICLE'],
        'OTHER' => ['ANHYDROUS_AMMONIA_TANK', 'NURSE_TRUCK', 'NURSE_WAGON', 'TECHNICIAN_TRUCK']
      },
    }

    private

    ##
    # attributes that must be specified

    def required_attributes
      [:organization_id, :contribution_definition_id, :title]
    end

    ##
    # Retrieve newly created record

    def fetch_record
      path = response['location'].split('/platform').last
      result = accessor.get(path, headers)

      JSON.parse(result.body)
    end

    ##
    # This is the class used to model the data

    def model
      Model::Asset
    end

    ##
    # Handle any custom validation for this model that may not apply to others

    def validate_attributes
      unless valid_categories?(attributes[:asset_category], attributes[:asset_type], attributes[:asset_sub_type])
        errors[:asset_category] = 'requires valid combination of category/type/subtype'
      end
    end

    ##
    # Path supplied to API

    def resource
      @resource ||= "/organizations/#{attributes[:organization_id]}/assets"
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
    # Returns boolean, true if this combination is valid

    def valid_categories?(category, type, subtype)
      VALID_CATEGORIES.dig(category, type).to_a.include?(subtype)
    end
  end
end