require 'json'

module MyJohnDeereApi::Request
  class Collection::ContributionProducts < Collection::Base
    ##
    # The resource path for the first page in the collection

    def resource
      "/contributionProducts?clientControlled=true"
    end

    ##
    # This is the class used to model the data

    def model
      MyJohnDeereApi::Model::ContributionProduct
    end

    ##
    # Retrieve an item from JD

    def find(item_id)
      Individual::ContributionProduct.new(accessor, item_id).object
    end
  end
end