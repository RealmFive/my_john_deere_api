require 'support/helper'
require 'date'

describe 'MyJohnDeereApi::Request::Create::AssetLocation' do
  include JD::ResponseHelpers

  def attributes_without(*keys)
    keys = keys.to_a
    attributes.reject{|k,v| keys.include?(k)}
  end

  let(:valid_attributes) do
    CONFIG.asset_location_attributes.merge(
      asset_id: asset_id
    )
  end

  let(:attributes) { valid_attributes }

  let(:klass) { JD::Request::Create::AssetLocation }
  let(:object) { klass.new(client, attributes) }

  inherits_from MyJohnDeereApi::Request::Create::Base

  describe '#initialize(client, attributes)' do
    it 'accepts a client and attributes' do
      assert_equal client, object.client
      assert_equal attributes, object.attributes
    end

    it 'accepts simple coordinates and generates the geometry' do
      attributes = {
        asset_id: asset_id,
        timestamp: valid_attributes[:timestamp],
        coordinates: CONFIG.coordinates,
        measurement_data: valid_attributes[:measurement_data]
      }

      object = klass.new(client, attributes)
      assert_equal valid_attributes[:geometry].to_json, object.attributes[:geometry]
    end

    it 'defaults timestamp to current time' do
      attributes = valid_attributes.slice(:asset_id, :geometry, :measurement_data)
      object = klass.new(client, attributes)

      expected_stamp = Time.now.utc.to_i
      actual_stamp = DateTime.parse(object.attributes[:timestamp]).to_time.to_i

      assert_in_delta expected_stamp, actual_stamp, 1
    end
  end

  describe '#valid?' do
    it 'returns true when all required attributes are present' do
      assert object.valid?
      assert_empty object.errors
    end

    it 'requires asset_id' do
      object = klass.new(client, attributes_without(:asset_id))

      refute object.valid?
      assert_equal 'is required', object.errors[:asset_id]
    end

    it 'requires geometry' do
      object = klass.new(client, attributes_without(:geometry))

      refute object.valid?
      assert_equal 'is required', object.errors[:geometry]
    end

    it 'requires measurement_data' do
      object = klass.new(client, attributes_without(:measurement_data))

      refute object.valid?
      assert_equal 'is required', object.errors[:measurement_data]
    end

    describe 'validating measurement_data' do
      it 'must be an array' do
        object = klass.new(client, attributes.merge(measurement_data: 'something'))

        refute object.valid?
        assert_equal 'must be an array', object.errors[:measurement_data]
      end

      it 'must include a name' do
        without_attr = [attributes[:measurement_data].first.reject{|k,v| k == :name}]
        object = klass.new(client, attributes.merge(measurement_data: without_attr))

        refute object.valid?
        assert_equal 'must include name', object.errors[:measurement_data]
      end

      it 'must include a value' do
        without_attr = [attributes[:measurement_data].first.reject{|k,v| k == :value}]
        object = klass.new(client, attributes.merge(measurement_data: without_attr))

        refute object.valid?
        assert_equal 'must include value', object.errors[:measurement_data]
      end

      it 'must include a unit' do
        without_attr = [attributes[:measurement_data].first.reject{|k,v| k == :unit}]
        object = klass.new(client, attributes.merge(measurement_data: without_attr))

        refute object.valid?
        assert_equal 'must include unit', object.errors[:measurement_data]
      end
    end
  end

  describe '#validate!' do
    it 'raises an error when invalid' do
      object = klass.new(client, attributes_without(:asset_id))

      exception = assert_raises(JD::InvalidRecordError) { object.validate! }
      assert_includes exception.message, 'Record is invalid'
      assert_includes exception.message, 'asset_id is required'
    end
  end

  describe '#request_body' do
    it 'properly forms the request body' do
      body = object.send(:request_body)

      expected_stamp = DateTime.parse(attributes[:timestamp]).strftime('%Y-%m-%dT%H:%M:%S.000Z')

      assert_kind_of Array, body
      assert_equal expected_stamp, body.first[:timestamp]
      assert_equal attributes[:geometry], body.first[:geometry]
      assert_equal attributes[:measurement_data], body.first[:measurementData]
    end
  end

  describe '#request' do
    it 'makes the request' do
      VCR.use_cassette('post_asset_locations') { object.request }

      assert_created(object.response)
    end
  end

  describe '#object' do
    it 'returns the asset location model instance' do
      result = VCR.use_cassette('post_asset_locations') { object.object }

      assert_kind_of JD::Model::AssetLocation, result

      # API returns seconds with decimals, even though they're always zero
      integer_stamp = DateTime.parse(result.timestamp).strftime('%Y-%m-%dT%H:%M:%SZ')
      expected_stamp = DateTime.parse(attributes[:timestamp]).strftime('%Y-%m-%dT%H:%M:%SZ')

      # API returns string keys and an extra '@type' key
      result_measurement_data = result.measurement_data.first.transform_keys{|k| k.to_sym}.slice(:name, :value, :unit)

      assert_equal expected_stamp, integer_stamp
      assert_equal attributes[:geometry], result.geometry.to_json
      assert_equal attributes[:measurement_data].first, result_measurement_data
    end
  end
end