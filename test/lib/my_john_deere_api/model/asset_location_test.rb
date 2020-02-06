require 'support/helper'
require 'json'

describe 'MyJohnDeereApi::Model::AssetLocation' do
  let(:record) do
    {
      '@type' => 'ContributedAssetLocation',
      'timestamp' => CONFIG.timestamp,
      'geometry' => CONFIG.geometry.to_json,
      'measurementData' => CONFIG.measurement_data,
      'links' => []
    }
  end

  describe '#initialize' do
    def link_for label
      record['links'].detect{|link| link['rel'] == label}['uri'].gsub('https://sandboxapi.deere.com/platform', '')
    end

    it 'sets the attributes from the given record' do
      location = JD::Model::AssetLocation.new(record)

      assert_nil location.accessor

      # basic attributes
      assert_equal record['timestamp'], location.timestamp
      assert_equal JSON.parse(record['geometry']), location.geometry
      assert_equal record['measurementData'], location.measurement_data

      # links to other things
      assert_kind_of Hash, location.links
      assert_equal 0, location.links.size
    end

    it 'accepts an optional accessor' do
      mock_accessor = 'mock-accessor'

      location = JD::Model::AssetLocation.new(record, mock_accessor)
      assert_equal mock_accessor, location.accessor
    end
  end
end