require 'json'

module MyJohnDeereApi::Request
  class Individual::ContributionProduct < Individual::Base
    ##
    # The resource path for the first page in the collection

    def resource
      "/contributionProducts/#{id}"
    end

    ##
    # This is the class used to model the data

    def model
      MyJohnDeereApi::Model::ContributionProduct
    end
  end
end