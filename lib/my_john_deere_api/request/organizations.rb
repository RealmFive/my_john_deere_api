require 'json'

module MyJohnDeereApi::Request
  class Organizations < Collection
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
  end
end