require 'json'

module MyJohnDeereApi::Request
  class Individual::Organization < Individual::Base
    ##
    # The resource path for the first page in the collection

    def resource
      "/organizations/#{id}"
    end

    ##
    # This is the class used to model the data

    def model
      MyJohnDeereApi::Model::Organization
    end
  end
end