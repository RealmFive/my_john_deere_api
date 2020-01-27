require 'json'

module MyJohnDeereApi::Request
  class Individual::Asset < Individual::Base
    ##
    # The resource path for the first page in the collection

    def resource
      "/assets/#{id}"
    end

    ##
    # This is the class used to model the data

    def model
      MyJohnDeereApi::Model::Asset
    end
  end
end