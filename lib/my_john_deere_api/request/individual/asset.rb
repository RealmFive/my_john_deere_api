require 'json'

module MyJohnDeereApi::Request
  class Individual::Asset < Individual::Base
    ##
    # The resource path for the object

    def resource
      "/platform/assets/#{id}"
    end

    ##
    # This is the class used to model the data

    def model
      MyJohnDeereApi::Model::Asset
    end
  end
end