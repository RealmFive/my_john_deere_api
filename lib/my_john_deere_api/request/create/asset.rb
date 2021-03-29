require 'json'

module MyJohnDeereApi
  class Request::Create::Asset < Request::Create::Base
    include Validators::Asset
    include Helpers::ValidateContributionDefinition

    private

    ##
    # id of newly created record

    def record_id
      response.headers['location'].split('/').last
    end

    ##
    # This is the class used to fetch an individual item

    def individual_class
      Request::Individual::Asset
    end

    ##
    # Path supplied to API

    def resource
      @resource ||= "/platform/organizations/#{attributes[:organization_id]}/assets"
    end

    ##
    # Request body

    def request_body
      return @body if defined?(@body)

      validate_contribution_definition

      @body = {
        title: attributes[:title],
        assetCategory: attributes[:asset_category],
        assetType: attributes[:asset_type],
        assetSubType: attributes[:asset_sub_type],
        links: [
          {
            '@type' => 'Link',
            'rel' => 'contributionDefinition',
            'uri' => client.contribution_definition_uri,
          }
        ]
      }
    end
  end
end