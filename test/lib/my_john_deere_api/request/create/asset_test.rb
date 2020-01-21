require 'support/helper'

describe 'MyJohnDeereApi::Request::Create::Asset' do
  def attributes_without(*keys)
    keys = keys.to_a
    attributes.reject{|k,v| keys.include?(k)}
  end

  let(:client) { JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET]) }
  let(:accessor) { VCR.use_cassette('catalog') { client.send(:accessor) } }

  let(:organization_id) { ENV['ORGANIZATION_ID']}
  let(:contribution_definition_id) { ENV['CONTRIBUTION_DEFINITION_ID']}
  let(:title) { 'i like turtles' }
  let(:category) { 'DEVICE' }
  let(:type) { 'SENSOR' }
  let(:subtype) { 'ENVIRONMENTAL' }

  let(:valid_attributes) do
    {
      organization_id: organization_id,
      contribution_definition_id: contribution_definition_id,
      title: title,
      asset_category: category,
      asset_type: type,
      asset_sub_type: subtype,
    }
  end

  let(:object) { JD::Request::Create::Asset.new(accessor, attributes) }

  let(:attributes) { valid_attributes }

  inherits_from MyJohnDeereApi::Request::Create::Base

  describe '#initialize(access_token, attributes)' do
    it 'accepts an accessor and attributes' do
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
      object = JD::Request::Create::Asset.new(accessor, attributes.merge(asset_category: 'TURTLES'))

      refute object.valid?
      assert_equal 'requires valid combination of category/type/subtype', object.errors[:asset_category]
    end

    it 'requires a valid type' do
      object = JD::Request::Create::Asset.new(accessor, attributes.merge(asset_type: 'TURTLES'))

      refute object.valid?
      assert_equal 'requires valid combination of category/type/subtype', object.errors[:asset_category]
    end

    it 'requires a valid subtype' do
      object = JD::Request::Create::Asset.new(accessor, attributes.merge(asset_sub_type: 'TURTLES'))

      refute object.valid?
      assert_equal 'requires valid combination of category/type/subtype', object.errors[:asset_category]
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

  describe '#resource' do
    it 'is built from the organization id' do
      object = JD::Request::Create::Asset.new(accessor, attributes)
      assert_equal "/organizations/#{organization_id}/assets", object.send(:resource)
    end
  end

  describe '#request_body' do
    it 'properly forms the request body' do
      object = JD::Request::Create::Asset.new(accessor, attributes)
      body = object.send(:request_body)

      assert_equal title, body[:title]
      assert_equal category, body[:assetCategory]
      assert_equal type, body[:assetType]
      assert_equal subtype, body[:assetSubType]

      assert_kind_of Array, body[:links]
      assert_equal 1, body[:links].size

      assert_kind_of Hash, body[:links].first
      assert_equal 'Link', body[:links].first['@type']
      assert_equal 'contributionDefinition', body[:links].first['rel']
      assert_equal  "#{ENV['BASE_URL']}/platform/contributionDefinitions/#{contribution_definition_id}",
                    body[:links].first['uri']
    end
  end

  describe '#request' do
    it 'makes the request' do
      VCR.use_cassette('post_assets') { object.request }

      assert_kind_of Net::HTTPCreated, object.response
    end
  end

  describe '#object' do
    it 'returns the asset model instance' do
      object = JD::Request::Create::Asset.new(accessor, attributes)
      result = VCR.use_cassette('post_assets') { object.object }

      assert_kind_of JD::Model::Asset, result

      expected_id = object.response['location'].split('/').last

      assert_equal expected_id, result.id
      assert_equal title, result.title
      assert_equal category, result.asset_category
      assert_equal type, result.asset_type
      assert_equal subtype, result.asset_sub_type
    end
  end
end