module MyJohnDeereApi
  class Model::ContributionProduct < Model::Base
    attr_reader :market_place_name, :market_place_description, :default_locale,
                :current_status, :activation_callback, :preview_images,
                :supported_regions, :supported_operation_centers


    ##
    # contribution definitions associated with this contribution product

    def contribution_definitions
      return @contribution_definitions if defined?(@contribution_definitions)
      @contribution_definitions = Request::Collection::ContributionDefinitions.new(accessor, contribution_product: id)
    end

    private

    def map_attributes(record)
      @market_place_name =            record['marketPlaceName']
      @market_place_description =     record['marketPlaceDescription']
      @default_locale =               record['defaultLocale']
      @current_status =               record['currentStatus']
      @activation_callback =          record['activationCallback']
      @preview_images =               record['previewImages']
      @supported_regions =            record['supportedRegions']
      @supported_operation_centers =  record['supportedOperationCenters']
    end

    def expected_record_type
      'ContributionProduct'
    end
  end
end