require 'json'

module MyJohnDeereApi::Request
  class Collection::Flags < Collection::Base
    ##
    # The resource path for the first page in the collection

    def resource
      "/platform/organizations/#{associations[:organization]}/fields/#{associations[:field]}/flags"
    end

    ##
    # This is the class used to model the data

    def model
      MyJohnDeereApi::Model::Flag
    end

    ##
    # Create a new flag (NOT YET IMPLEMENTED)

    def create(attributes)
      raise NotImplementedError
    end

    ##
    # Retrieve an flag from JD (NOT YET IMPLEMENTED)

    def find(asset_id)
      raise NotImplementedError
    end
  end
end