require 'json'

module MyJohnDeereApi::Request
  class Individual::Field < Individual::Base
    ##
    # The resource path for the first page in the collection

    def resource
      "/platform/organizations/#{associations[:organization]}/fields/#{id}"
    end

    ##
    # This is the class used to model the data

    def model
      MyJohnDeereApi::Model::Field
    end
  end
end