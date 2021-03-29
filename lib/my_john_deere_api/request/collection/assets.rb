require 'json'

module MyJohnDeereApi::Request
  class Collection::Assets < Collection::Base
    ##
    # The resource path for the first page in the collection

    def resource
      "/platform/organizations/#{associations[:organization]}/assets"
    end

    ##
    # This is the class used to model the data

    def model
      MyJohnDeereApi::Model::Asset
    end

    ##
    # Create a new asset

    def create(attributes)
      merged_attributes = attributes.merge(organization_id: associations[:organization])
      Create::Asset.new(client, merged_attributes).object
    end

    ##
    # Retrieve an asset from JD

    def find(asset_id)
      Individual::Asset.new(client, asset_id).object
    end
  end
end