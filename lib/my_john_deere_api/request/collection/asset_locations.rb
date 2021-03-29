require 'json'

module MyJohnDeereApi::Request
  class Collection::AssetLocations < Collection::Base
    ##
    # The resource path for the first page in the collection

    def resource
      "/platform/assets/#{associations[:asset]}/locations"
    end

    ##
    # This is the class used to model the data

    def model
      MyJohnDeereApi::Model::AssetLocation
    end

    ##
    # Create a new asset location

    def create(attributes)
      merged_attributes = attributes.merge(asset_id: associations[:asset])
      Create::AssetLocation.new(client, merged_attributes).object
    end
  end
end