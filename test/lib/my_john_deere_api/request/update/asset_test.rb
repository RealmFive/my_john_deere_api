require 'support/helper'

describe 'MyJohnDeereApi::Request::Update::Asset' do
  let(:klass) { JD::Request::Update::Asset }
  let(:object) { klass.new(accessor, item, attributes) }
  let(:item) { JD::Model::Asset.new(record, accessor) }

  let(:attributes) do
    {
      organization_id: organization_id,
      contribution_definition_id: contribution_definition_id
    }
  end

  let(:record) do
    {
      '@type' => 'ContributedAsset',
      'id' => asset_id,
      'title' => 'Bob',
      'assetCategory' => 'DEVICE',
      'assetType' => 'SENSOR',
      'assetSubType' => 'ENVIRONMENTAL',
      'lastModifiedDate' => CONFIG.timestamp,
      'links' => []
    }
  end

  inherits_from MyJohnDeereApi::Request::Update::Base

  describe '#initialize(access_token, item, attributes)' do
    it 'accepts an accessor, item and attributes' do
      assert_equal accessor, object.accessor
      assert_equal item, object.item
      assert_equal item.attributes.merge(attributes), object.attributes
    end

    it 'includes validation' do
      [:validate!, :valid?].each do |method_name|
        assert object.respond_to?(method_name)
      end
    end
  end

  describe '#resource' do
    it 'is /assets/<asset_id>' do
      assert_equal "/assets/#{asset_id}", object.send(:resource)
    end
  end

  describe '#headers' do
    it 'sets the accept and content-type headers' do
      object = JD::Request::Update::Asset.new(accessor, item, attributes)
      headers = object.send(:headers)

      expected = 'application/vnd.deere.axiom.v3+json'

      assert_kind_of Hash, headers
      assert_equal expected, headers['Accept']
      assert_equal expected, headers['Content-Type']
    end
  end

  describe '#request_body' do
    it 'properly forms the request body' do
      body = object.send(:request_body)

      assert_equal item.attributes[:title], body[:title]
      assert_equal item.attributes[:asset_category], body[:assetCategory]
      assert_equal item.attributes[:asset_type], body[:assetType]
      assert_equal item.attributes[:asset_sub_type], body[:assetSubType]

      assert_kind_of Array, body[:links]
      assert_equal 1, body[:links].size

      assert_kind_of Hash, body[:links].first
      assert_equal 'Link', body[:links].first['@type']
      assert_equal 'contributionDefinition', body[:links].first['rel']
      assert_equal  "#{base_url}/contributionDefinitions/#{contribution_definition_id}",
                    body[:links].first['uri']
    end
  end

  describe '#request' do
    it 'makes the request' do
      VCR.use_cassette('put_asset') { object.request }

      assert_kind_of Net::HTTPNoContent, object.response
    end
  end
end