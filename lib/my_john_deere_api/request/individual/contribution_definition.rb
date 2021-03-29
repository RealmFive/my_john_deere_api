require 'json'

module MyJohnDeereApi::Request
  class Individual::ContributionDefinition < Individual::Base
    ##
    # The resource path for the first page in the collection

    def resource
      "/platform/contributionDefinitions/#{id}"
    end

    ##
    # This is the class used to model the data

    def model
      MyJohnDeereApi::Model::ContributionDefinition
    end
  end
end