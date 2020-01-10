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
  end
end