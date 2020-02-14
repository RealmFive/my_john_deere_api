require 'json'

module MyJohnDeereApi::Request
  class Collection::Organizations < Collection::Base
    ##
    # The resource path for the first page in the collection

    def resource
      '/organizations'
    end

    ##
    # This is the class used to model the data

    def model
      MyJohnDeereApi::Model::Organization
    end

    ##
    # Retrieve an organization from JD

    def find(organization_id)
      Individual::Organization.new(client, organization_id).object
    end
  end
end