require 'json'

module MyJohnDeereApi::Request
  class Collection::Fields < Collection::Base
    ##
    # The resource path for the first page in the collection

    def resource
      "/organizations/#{associations[:organization]}/fields"
    end

    ##
    # This is the class used to model the data

    def model
      MyJohnDeereApi::Model::Field
    end
  end
end