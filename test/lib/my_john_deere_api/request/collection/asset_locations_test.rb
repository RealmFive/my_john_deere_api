require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Collection::AssetLocations' do
  let(:asset_id) do
    contents = File.read('test/support/vcr/get_assets.yml')
    body = YAML.load(contents)['http_interactions'].first['response']['body']['string']
    JSON.parse(body)['values'].first['id']
  end

  let(:client) { JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET]) }
  let(:accessor) { VCR.use_cassette('catalog') { client.send(:accessor) } }
  let(:collection) { JD::Request::Collection::AssetLocations.new(accessor, asset: asset_id) }
  let(:object) { collection }

  inherits_from JD::Request::Collection::Base

  describe '#initialize(access_token)' do
    it 'accepts an access token' do
      assert_kind_of OAuth::AccessToken, collection.accessor
    end

    it 'accepts associations' do
      collection = JD::Request::Collection::AssetLocations.new(accessor, asset: '123')

      assert_kind_of Hash, collection.associations
      assert_equal '123', collection.associations[:asset]
    end
  end

  describe '#resource' do
    it 'returns /assets/{asset_id}/locations' do
      assert_equal "/assets/#{asset_id}/locations", collection.resource
    end
  end

  describe '#all' do
    it 'returns all records' do
      all = VCR.use_cassette('get_asset_locations') { collection.all }

      assert_kind_of Array, all
      assert_equal collection.count, all.size
      assert all.size > 0

      all.each do |item|
        assert_kind_of JD::Model::AssetLocation, item
      end
    end
  end

  describe '#create(attributes)' do
    let(:asset_id) { ENV['ASSET_ID'] }
    let(:timestamp) { DateTime.parse(timestamp_string) }
    let(:timestamp_string) { '2020-01-21T10:49:00Z' }
    let(:coordinates) { [-103.115633, 41.670166] }

    let(:geometry) do
      {
        type: 'Feature',
        geometry: {
          geometries: [
            coordinates: coordinates,
            type: 'Point'
          ],
          type: 'GeometryCollection'
        }
      }
    end

    let(:measurement_data) do
      [
        {
          name: 'Temperature',
          value: '68.0',
          unit: 'F'
        }
      ]
    end

    it 'creates a new asset with the given attributes' do
      attributes = {
        timestamp: timestamp,
        geometry: geometry,
        measurement_data: measurement_data
      }

      object = VCR.use_cassette('post_asset_locations') { collection.create(attributes) }

      assert_kind_of JD::Model::AssetLocation, object

      # API returns seconds with decimals, even though they're always zero
      integer_stamp = DateTime.parse(object.timestamp).strftime('%Y-%m-%dT%H:%M:%SZ')

      # API returns string keys and an extra '@type' key
      object_measurement_data = object.measurement_data.first.transform_keys{|k| k.to_sym}.slice(:name, :value, :unit)

      assert_equal timestamp_string, integer_stamp
      assert_equal geometry.to_json, object.geometry.to_json
      assert_equal measurement_data.first, object_measurement_data
    end
  end

  describe '#count' do
    let(:server_response) do
      contents = File.read('test/support/vcr/get_asset_locations.yml')
      body = YAML.load(contents)['http_interactions'].first['response']['body']['string']
      JSON.parse(body)
    end

    let(:server_count) { server_response['total'] }

    it 'returns the total count of records in the collection' do
      count = VCR.use_cassette('get_asset_locations') { collection.count }

      assert_equal server_count, count
    end
  end

  describe 'results' do
    let(:location_timestamps) do
      contents = File.read('test/support/vcr/get_asset_locations.yml')
      body = YAML.load(contents)['http_interactions'].first['response']['body']['string']
      JSON.parse(body)['values'].map{|v| v['timestamp']}
    end

    it 'returns all records as a single enumerator' do
      count = VCR.use_cassette('get_asset_locations') { collection.count }
      timestamps = VCR.use_cassette('get_asset_locations') { collection.map(&:timestamp) }

      assert_kind_of Array, timestamps
      assert_equal count, timestamps.size
      assert timestamps.size > 0

      location_timestamps.each do |expected_timestamp|
        assert_includes timestamps, expected_timestamp
      end
    end
  end
end