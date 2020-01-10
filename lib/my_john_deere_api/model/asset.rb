module MyJohnDeereApi
  class Model::Asset
    include Helpers::UriHelpers

    attr_reader :accessor, :id, :title, :asset_category, :asset_type, :asset_sub_type, :last_modified_date, :links

    ##
    # arguments:
    #
    # [record] a JSON object of type 'Field', returned from the API.
    #
    # [accessor (optional)] a valid oAuth Access Token. This is only
    #                       needed if further API requests are going
    #                       to be made, as is the case with *flags*.

    def initialize(record, accessor = nil)
      @accessor = accessor

      @id = record['id']
      @title = record['title']
      @asset_category = record['assetCategory']
      @asset_type = record['assetType']
      @asset_sub_type = record['assetSubType']
      @last_modified_date = record['lastModifiedDate']

      @links = {}

      record['links'].each do |association|
        @links[association['rel']] = uri_path(association['uri'])
      end
    end

    ##
    # locations associated with this asset

    def locations
      raise AccessTokenError unless accessor

      return @locations if defined?(@locations)
      @locations = MyJohnDeereApi::Request::Collection::AssetLocations.new(accessor, asset: id).all
    end
  end
end