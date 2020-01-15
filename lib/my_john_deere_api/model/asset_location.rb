require 'json'

module MyJohnDeereApi
  class Model::AssetLocation < Model::Base
    attr_reader :timestamp, :geometry, :measurement_data

    private

    def map_attributes(record)
      @timestamp = record['timestamp']
      @geometry = JSON.parse(record['geometry'])
      @measurement_data = record['measurementData']
    end

    def expected_record_type
      'ContributedAssetLocation'
    end
  end
end