module MyJohnDeereApi
  class Model::Asset < Model::Base
    attr_reader :title, :asset_category, :asset_type, :asset_sub_type, :last_modified_date

    ##
    # A listing of attributes that can be passed back to John Deere

    def attributes
      {
        id: id,
        title: title,
        asset_category: asset_category,
        asset_type: asset_type,
        asset_sub_type: asset_sub_type
      }
    end

    ##
    # locations associated with this asset

    def locations
      raise AccessTokenError unless accessor

      return @locations if defined?(@locations)
      @locations = MyJohnDeereApi::Request::Collection::AssetLocations.new(accessor, asset: id)
    end

    private

    def map_attributes(record)
      @title = record['title']
      @asset_category = record['assetCategory']
      @asset_type = record['assetType']
      @asset_sub_type = record['assetSubType']
      @last_modified_date = record['lastModifiedDate']
    end

    def expected_record_type
      'ContributedAsset'
    end
  end
end