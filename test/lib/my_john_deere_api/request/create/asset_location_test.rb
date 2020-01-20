require 'support/helper'
require 'date'

describe 'MyJohnDeereApi::Request::Create::AssetLocation' do
  def attributes_without(*keys)
    keys = keys.to_a
    attributes.reject{|k,v| keys.include?(k)}
  end

  let(:client) { JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET]) }
  let(:accessor) { VCR.use_cassette('catalog') { client.send(:accessor) } }

  let(:asset_id) { ENV['ASSET_ID'] }
  let(:timestamp) { DateTime.parse(timestamp_string) }
  let(:timestamp_string) { '2020-01-18T00:31:00Z' }

  let(:geometry) do
    {
      type: 'Point',
      coordinates: [-103.115633, 41.670166]
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

  let(:valid_attributes) do
    {
      asset_id: asset_id,
      timestamp: timestamp,
      geometry: geometry,
      measurement_data: measurement_data
    }
  end

  let(:attributes) { valid_attributes }

  describe '#initialize(access_token, attributes)' do
    it 'accepts an accessor and attributes' do
      object = JD::Request::Create::AssetLocation.new(accessor, attributes)

      assert_equal accessor, object.accessor
      assert_equal attributes, object.attributes
    end

    it 'creates an empty error hash' do
      object = JD::Request::Create::AssetLocation.new(accessor, {})
      assert_equal({}, object.errors)
    end

    it 'accepts simple coordinates and generates the geometry' do
      attributes = {
        asset_id: asset_id,
        timestamp: timestamp,
        coordinates: geometry[:coordinates],
        measurement_data: measurement_data
      }

      object = JD::Request::Create::AssetLocation.new(accessor, attributes)

      expected_geometry = {
        type: 'Feature',
        geometry: {
          geometries: [
            coordinates: geometry[:coordinates],
            type: 'Point'
          ],
          type: 'GeometryCollection'
        }
      }.to_json

      assert_equal expected_geometry, object.send(:geometry)
    end

    it 'defaults timestamp to current time' do
      attributes = valid_attributes.slice(:asset_id, :geometry, :measurement_data)
      object = JD::Request::Create::AssetLocation.new(accessor, attributes)

      expected_stamp = Time.now.utc.to_i
      actual_stamp = DateTime.parse(object.send(:timestamp)).to_time.to_i

      assert_in_delta expected_stamp, actual_stamp, 1
    end
  end

  describe '#valid?' do
    it 'returns true when all required attributes are present' do
      object = JD::Request::Create::AssetLocation.new(accessor, attributes)

      assert object.valid?
      assert_empty object.errors
    end

    it 'requires asset_id' do
      object = JD::Request::Create::AssetLocation.new(accessor, attributes_without(:asset_id))

      refute object.valid?
      assert_equal 'is required', object.errors[:asset_id]
    end

    it 'requires timestamp' do
      object = JD::Request::Create::AssetLocation.new(accessor, attributes_without(:timestamp))

      refute object.valid?
      assert_equal 'is required', object.errors[:timestamp]
    end

    it 'requires geometry' do
      object = JD::Request::Create::AssetLocation.new(accessor, attributes_without(:geometry))

      refute object.valid?
      assert_equal 'is required', object.errors[:geometry]
    end

    it 'requires measurement_data' do
      object = JD::Request::Create::AssetLocation.new(accessor, attributes_without(:measurement_data))

      refute object.valid?
      assert_equal 'is required', object.errors[:measurement_data]
    end

    describe 'validating measurement_data' do
      it 'must be an array' do
        object = JD::Request::Create::AssetLocation.new(accessor, attributes.merge(measurement_data: 'something'))

        refute object.valid?
        assert_equal 'must be an array', object.errors[:measurement_data]
      end

      it 'must include a name' do
        without_attr = [measurement_data.first.reject{|k,v| k == :name}]
        object = JD::Request::Create::AssetLocation.new(accessor, attributes.merge(measurement_data: without_attr))

        refute object.valid?
        assert_equal 'must include name', object.errors[:measurement_data]
      end

      it 'must include a value' do
        without_attr = [measurement_data.first.reject{|k,v| k == :value}]
        object = JD::Request::Create::AssetLocation.new(accessor, attributes.merge(measurement_data: without_attr))

        refute object.valid?
        assert_equal 'must include value', object.errors[:measurement_data]
      end

      it 'must include a unit' do
        without_attr = [measurement_data.first.reject{|k,v| k == :unit}]
        object = JD::Request::Create::AssetLocation.new(accessor, attributes.merge(measurement_data: without_attr))

        refute object.valid?
        assert_equal 'must include unit', object.errors[:measurement_data]
      end
    end
  end

  describe '#validate!' do
    it 'raises an error when invalid' do
      object = JD::Request::Create::AssetLocation.new(accessor, attributes_without(:asset_id))

      exception = assert_raises(JD::InvalidRecordError) { object.validate! }
      assert_includes exception.message, 'Record is invalid'
      assert_includes exception.message, 'asset_id is required'
    end
  end

  describe '#request_body' do
    it 'properly forms the request body' do
      object = JD::Request::Create::AssetLocation.new(accessor, attributes)
      body = object.send(:request_body)

      assert_kind_of Array, body
      assert_equal timestamp_string, body.first[:timestamp]
      assert_equal geometry.to_json, body.first[:geometry]
      assert_equal measurement_data, body.first[:measurementData]
    end
  end

  describe '#request' do
    it 'makes the request' do
      object = JD::Request::Create::AssetLocation.new(accessor, attributes)
      VCR.use_cassette('post_asset_locations') { object.request }

      assert_kind_of Net::HTTPCreated, object.response
    end
  end

  describe '#object' do
    it 'returns the asset location model instance' do
      object = JD::Request::Create::AssetLocation.new(accessor, attributes)
      result = VCR.use_cassette('post_asset_locations') { object.object }

      assert_kind_of JD::Model::AssetLocation, result

      # API returns seconds with decimals, even though they're always zero
      integer_stamp = DateTime.parse(result.timestamp).strftime('%Y-%m-%dT%H:%M:%SZ')

      # API returns string keys and an extra '@type' key
      result_measurement_data = result.measurement_data.first.transform_keys{|k| k.to_sym}.slice(:name, :value, :unit)

      assert_equal timestamp_string, integer_stamp
      assert_equal geometry.to_json, result.geometry.to_json
      assert_equal measurement_data.first, result_measurement_data
    end
  end
end