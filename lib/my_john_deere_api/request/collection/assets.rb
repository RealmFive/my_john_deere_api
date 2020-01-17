require 'json'

module MyJohnDeereApi::Request
  class Collection::Assets < Collection::Base
    ##
    # The resource path for the first page in the collection

    def resource
      "/organizations/#{associations[:organization]}/assets"
    end

    ##
    # This is the class used to model the data

    def model
      MyJohnDeereApi::Model::Asset
    end

    ##
    # Create a new asset

    def create(attributes)
      attributes.merge!(organization_id: associations[:organization])
      Create::Asset.new(accessor, attributes).object
    end
  end
end