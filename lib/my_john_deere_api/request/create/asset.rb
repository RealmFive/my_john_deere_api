require 'json'

module MyJohnDeereApi
  class Request::Create::Asset < Request::Create::Base
    include Validators::Asset

    private

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
    # Path supplied to API

    def resource
      @resource ||= "/organizations/#{attributes[:organization_id]}/assets"
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