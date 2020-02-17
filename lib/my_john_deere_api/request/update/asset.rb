require 'json'

module MyJohnDeereApi
  class Request::Update::Asset < Request::Update::Base
    include Validators::Asset
    include Helpers::ValidateContributionDefinition

    private

    ##
    # Path supplied to API

    def resource
      @resource ||= "/assets/#{attributes[:id]}"
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
            'uri' => "#{accessor.consumer.site}/contributionDefinitions/#{client.contribution_definition_id}"
          }
        ]
      }
    end
  end
end