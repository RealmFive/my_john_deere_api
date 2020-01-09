require 'json'

module MyJohnDeereApi::Request
  class Collection::Flags < Collection::Base
    ##
    # The resource path for the first page in the collection

    def resource
      "/organizations/#{associations[:organization]}/fields/#{associations[:field]}/flags"
    end

    ##
    # This is the class used to model the data

    def model
      MyJohnDeereApi::Model::Flag
    end
  end
end