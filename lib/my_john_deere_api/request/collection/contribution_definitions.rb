require 'json'

module MyJohnDeereApi::Request
  class Collection::ContributionDefinitions < Collection::Base
    ##
    # The resource path for the first page in the collection

    def resource
      "/contributionProducts/#{associations[:contribution_product]}/contributionDefinitions"
    end

    ##
    # This is the class used to model the data

    def model
      MyJohnDeereApi::Model::ContributionDefinition
    end

    ##
    # Retrieve an item from JD

    def find(item_id)
      Individual::ContributionDefinition.new(accessor, item_id).object
    end
  end
end