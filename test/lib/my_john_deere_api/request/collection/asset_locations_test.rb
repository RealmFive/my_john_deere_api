require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Collection::AssetLocations' do
  let(:klass) { JD::Request::Collection::AssetLocations }
  let(:collection) { klass.new(client, asset: asset_id) }
  let(:object) { collection }

  inherits_from JD::Request::Collection::Base

  describe '#initialize(client)' do
    it 'accepts a client' do
      assert_equal client, collection.client
    end

    it 'accepts associations' do
      collection = klass.new(client, asset: asset_id)

      assert_kind_of Hash, collection.associations
      assert_equal asset_id, collection.associations[:asset]
    end
  end

  describe '#resource' do
    it 'returns /platform/assets/{asset_id}/locations' do
      assert_equal "/platform/assets/#{asset_id}/locations", collection.resource
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
    it 'creates a new asset with the given attributes' do
      attributes = CONFIG.asset_location_attributes

      object = VCR.use_cassette('post_asset_locations') { collection.create(attributes) }

      assert_kind_of JD::Model::AssetLocation, object

      # API returns seconds with decimals, even though they're always zero
      integer_stamp = DateTime.parse(object.timestamp).strftime('%Y-%m-%dT%H:%M:%SZ')
      expected_stamp = DateTime.parse(attributes[:timestamp]).strftime('%Y-%m-%dT%H:%M:%SZ')

      # API returns string keys and an extra '@type' key
      object_measurement_data = object.measurement_data.first.transform_keys{|k| k.to_sym}.slice(:name, :value, :unit)

      assert_equal expected_stamp, integer_stamp
      assert_equal attributes[:geometry].to_json, object.geometry.to_json
      assert_equal attributes[:measurement_data].first, object_measurement_data
    end
  end

  describe '#count' do
    let(:server_response) do
      contents = File.read('test/support/vcr/get_asset_locations.yml')
      body = YAML.load(contents)['http_interactions'].last['response']['body']['string']
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
      body = YAML.load(contents)['http_interactions'].last['response']['body']['string']
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