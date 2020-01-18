require 'json'

module MyJohnDeereApi::Request
  class Collection::AssetLocations < Collection::Base
    ##
    # The resource path for the first page in the collection

    def resource
      "/assets/#{associations[:asset]}/locations"
    end

    ##
    # This is the class used to model the data

    def model
      MyJohnDeereApi::Model::AssetLocation
    end

    ##
    # Create a new asset location

    def create(attributes)
      attributes.merge!(asset_id: associations[:asset])
      Create::AssetLocation.new(accessor, attributes).object
    end
  end
end