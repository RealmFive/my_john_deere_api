require 'support/helper'

class AssetLocationValidatorTest
  include JD::Validators::AssetLocation

  attr_reader :attributes

  def initialize(attributes)
    @attributes = attributes
  end
end

describe 'MyJohnDeereApi::Validators::AssetLocation' do
  let(:klass) { AssetLocationValidatorTest }
  let(:object) { klass.new(attributes) }
  let(:attributes) { valid_attributes }

  let(:valid_attributes) do
    {
      asset_id: asset_id,
      timestamp: CONFIG.timestamp,
      coordinates: CONFIG.coordinates,
      measurement_data: CONFIG.measurement_data
    }
  end

  it 'exists' do
    assert JD::Validators::AssetLocation
  end

  it 'inherits from MyJohnDeereApi::Validators::Base' do
    [:validate!, :valid?].each{ |method_name| assert object.respond_to?(method_name) }
  end

  it 'requires several attributes' do
    [:asset_id, :timestamp, :geometry, :measurement_data].each do |attr|
      object = klass.new(valid_attributes.merge(attr => nil))

      refute object.valid?
      exception = assert_raises(JD::InvalidRecordError) { object.validate! }

      assert_includes exception.message, "#{attr} is required"
      assert_includes object.errors[attr], 'is required'
    end
  end

  it 'requires measurement_data to have the right keys' do
    [:name, :value, :unit].each do |key|
      attributes = Marshal.load(Marshal.dump(valid_attributes))
      attributes[:measurement_data].first.delete(key)

      object = klass.new(attributes)

      refute object.valid?
      exception = assert_raises(JD::InvalidRecordError) { object.validate! }

      assert_includes exception.message, "measurement_data must include #{key}"
      assert_includes object.errors[:measurement_data], "must include #{key}"
    end
  end
end