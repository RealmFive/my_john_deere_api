module MyJohnDeereApi
  class Model::Asset < Model::Base
    include Helpers::CaseConversion

    attr_reader :title, :asset_category, :asset_type, :asset_sub_type, :last_modified_date

    ##
    # A listing of attributes that can be passed back to John Deere

    def attributes
      {
        id: id,
        title: title,
        asset_category: asset_category,
        asset_type: asset_type,
        asset_sub_type: asset_sub_type,
        organization_id: 'placeholder'
      }
    end

    ##
    # Change the title, locally

    def title=(value)
      mark_as_unsaved
      @title = value
    end

    ##
    # Save any attribute changes to John Deere

    def save
      if unsaved?
        mark_as_saved
        Request::Update::Asset.new(client, self, attributes).request
      end
    end

    ##
    # Update the attributes in John Deere

    def update new_attributes
      map_attributes(camelize(new_attributes))
      Request::Update::Asset.new(client, self, attributes).request
    end

    ##
    # locations associated with this asset

    def locations
      return @locations if defined?(@locations)
      @locations = Request::Collection::AssetLocations.new(client, asset: id)
    end

    private

    def map_attributes(record)
      @title = record['title'] if record['title']
      @asset_category = record['assetCategory'] if record['assetCategory']
      @asset_type = record['assetType'] if record['assetType']
      @asset_sub_type = record['assetSubType'] if record['assetSubType']
      @last_modified_date = record['lastModifiedDate'] if record['lastModifiedDate']
    end

    def expected_record_type
      'ContributedAsset'
    end
  end
end