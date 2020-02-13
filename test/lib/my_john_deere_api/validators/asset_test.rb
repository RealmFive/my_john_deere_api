require 'support/helper'

class AssetValidatorTest
  include JD::Validators::Asset

  attr_reader :attributes

  def initialize(attributes)
    @attributes = attributes
  end
end

describe 'MyJohnDeereApi::Validators::Asset' do
  let(:klass) { AssetValidatorTest }
  let(:object) { klass.new(attributes) }
  let(:attributes) { valid_attributes }

  let(:valid_attributes) do
    {
      organization_id: '000000',
      contribution_definition_id: '00000000-0000-0000-0000-000000000000',
      title: "Bob's Stuff"
    }
  end

  it 'exists' do
    assert JD::Validators::Asset
  end

  it 'inherits from MyJohnDeereApi::Validators::Base' do
    [:validate!, :valid?].each{ |method_name| assert object.respond_to?(method_name) }
  end

  it 'requires several attributes' do
    [:organization_id, :contribution_definition_id, :title].each do |attr|
      object = klass.new(valid_attributes.merge(attr => nil))

      refute object.valid?
      exception = assert_raises(JD::InvalidRecordError) { object.validate! }

      assert_includes exception.message, "#{attr} is required"
      assert_includes object.errors[attr], 'is required'
    end
  end

  it 'requires a valid combination of category/type/subtype' do
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

    error_message = 'requires valid combination of category/type/subtype'

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
          categories = {
            asset_category: category,
            asset_type: type,
            asset_sub_type: subtype
          }

          object = klass.new(valid_attributes.merge(categories))

          if valid_combos.include?([category, type, subtype])
            assert object.valid?
          else
            refute object.valid?
            exception = assert_raises(JD::InvalidRecordError) { object.validate! }

            assert_includes exception.message, "asset_category #{error_message}"
            assert_includes object.errors[:asset_category], error_message
          end
        end
      end
    end
  end
end