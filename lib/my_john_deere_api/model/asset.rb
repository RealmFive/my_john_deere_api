module MyJohnDeereApi
  class Model::Asset < Model::Base
    attr_reader :title, :asset_category, :asset_type, :asset_sub_type, :last_modified_date

    ##
    # locations associated with this asset

    def locations
      raise AccessTokenError unless accessor

      return @locations if defined?(@locations)
      @locations = MyJohnDeereApi::Request::Collection::AssetLocations.new(accessor, asset: id).all
    end

    private

    def map_attributes(record)
      @title = record['title']
      @asset_category = record['assetCategory']
      @asset_type = record['assetType']
      @asset_sub_type = record['assetSubType']
      @last_modified_date = record['lastModifiedDate']
    end
  end
end