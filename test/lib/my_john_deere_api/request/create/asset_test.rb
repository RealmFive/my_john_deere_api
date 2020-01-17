require 'support/helper'

describe 'MyJohnDeereApi::Request::Create::Asset' do
  def attributes_without(*keys)
    keys = keys.to_a
    attributes.reject{|k,v| keys.include?(k)}
  end

  let(:client) { JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET]) }
  let(:accessor) { VCR.use_cassette('catalog') { client.send(:accessor) } }

  let(:valid_attributes) do
    {
      organization_id: ENV['ORGANIZATION_ID'],
      contribution_definition_id: ENV['CONTRIBUTION_DEFINITION_ID'],
      title: 'i like turtles',
      category: 'DEVICE',
      type: 'SENSOR',
      subtype: 'ENVIRONMENTAL',
    }
  end

  let(:attributes) { valid_attributes }

  describe '#initialize(access_token, attributes)' do
    it 'accepts an accessor and attributes' do
      object = JD::Request::Create::Asset.new(accessor, attributes)

      assert_equal accessor, object.accessor
      assert_equal attributes, object.attributes
    end

    it 'creates an empty error hash' do
      object = JD::Request::Create::Asset.new(accessor, {})
      assert_equal({}, object.errors)
    end
  end

  describe '#valid?' do
    it 'returns true when all required attributes are present' do
      object = JD::Request::Create::Asset.new(accessor, attributes)

      assert object.valid?
      assert_empty object.errors
    end

    it 'requires organization_id' do
      object = JD::Request::Create::Asset.new(accessor, attributes_without(:organization_id))

      refute object.valid?
      assert_equal 'is required', object.errors[:organization_id]
    end

    it 'requires contribution_definition_id' do
      object = JD::Request::Create::Asset.new(accessor, attributes_without(:contribution_definition_id))

      refute object.valid?
      assert_equal 'is required', object.errors[:contribution_definition_id]
    end

    it 'requires title' do
      object = JD::Request::Create::Asset.new(accessor, attributes_without(:title))

      refute object.valid?
      assert_equal 'is required', object.errors[:title]
    end

    it 'requires a valid category' do
      object = JD::Request::Create::Asset.new(accessor, attributes.merge(category: 'TURTLES'))

      refute object.valid?
      assert_equal 'requires valid combination of category/type/subtype', object.errors[:category]
    end

    it 'requires a valid type' do
      object = JD::Request::Create::Asset.new(accessor, attributes.merge(type: 'TURTLES'))

      refute object.valid?
      assert_equal 'requires valid combination of category/type/subtype', object.errors[:category]
    end

    it 'requires a valid subtype' do
      object = JD::Request::Create::Asset.new(accessor, attributes.merge(subtype: 'TURTLES'))

      refute object.valid?
      assert_equal 'requires valid combination of category/type/subtype', object.errors[:category]
    end
  end

  describe '#validate!' do
    it 'raises an error when invalid' do
      object = JD::Request::Create::Asset.new(accessor, attributes_without(:organization_id))

      exception = assert_raises(JD::InvalidRecordError) { object.validate! }
      assert_includes exception.message, 'Record is invalid'
      assert_includes exception.message, 'organization_id is required'
    end
  end

  describe '#valid_categories?(category, type, subtype)' do
    it 'only allows pre-defined combinations' do
      object = JD::Request::Create::Asset.new(accessor, {})

      valid_combos = [
        ['DEVICE', 'SENSOR', 'ENVIRONMENTAL'],
        ['DEVICE', 'SENSOR', 'GRAIN_BIN'],
        ['DEVICE', 'SENSOR', 'IRRIGATION_PIVOT'],
        ['DEVICE', 'SENSOR', 'OTHER'],
        ['EQUIPMENT', 'MACHINE', 'PICKUP_TRUCK'],
        ['EQUIPMENT', 'MACHINE', 'UTILITY_VEHICLE'],
        ['EQUIPMENT', 'OTHER', 'ANHYDROUS_AMMONIA_TANK'],
        ['EQUIPMENT', 'OTHER', 'NURSE_TRUCK'],
        ['EQUIPMENT', 'OTHER', 'NURSE_WAGON'],
        ['EQUIPMENT', 'OTHER', 'TECHNICIAN_TRUCK']
      ]

      # cycle through all possible permutations, only proving valid if
      # listed above

      ['DEVICE', 'EQUIPMENT', 'RANDOM_INVALID'].each do |category|
        ['MACHINE', 'OTHER', 'SENSOR', 'RANDOM_INVALID'].each do |type|
          [
            'ANHYDROUS_AMMONIA_TANK', 'ENVIRONMENTAL', 'GRAIN_BIN',
            'IRRIGATION_PIVOT', 'NURSE_TRUCK', 'NURSE_WAGON',
            'OTHER', 'PICKUP_TRUCK', 'TECHNICIAN_TRUCK',
            'UTILITY_VEHICLE', 'RANDOM_INVALID'
          ].each do |subtype|
            if valid_combos.include?([category, type, subtype])
              assert object.send(:valid_categories?, category, type, subtype)
            else
              refute object.send(:valid_categories?, category, type, subtype)
            end
          end
        end
      end
    end
  end
end