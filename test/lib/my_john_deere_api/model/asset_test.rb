require 'support/helper'

describe 'MyJohnDeereApi::Model::Asset' do
  include JD::ResponseHelpers
  include JD::LinkHelpers

  let(:klass) { JD::Model::Asset }

  let(:record) do
    {
      "@type"=>"ContributedAsset",
      "title"=>"Happy Device",
      "assetCategory"=>"DEVICE",
      "assetType"=>"SENSOR",
      "assetSubType"=>"OTHER",
      "id"=>asset_id,
      "lastModifiedDate"=>"2018-01-31T20:36:16.727Z",
      "links"=>[
        {"@type"=>"Link", "rel"=>"self", "uri"=>"https://sandboxapi.deere.com/platform/assets/#{asset_id}"},
        {"@type"=>"Link", "rel"=>"organization", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}"},
        {"@type"=>"Link", "rel"=>"locations", "uri"=>"https://sandboxapi.deere.com/platform/assets/#{asset_id}/locations"},
      ]
    }
  end

  describe '#initialize' do
    it 'sets the attributes from the given record' do
      asset = klass.new(client, record)

      assert_equal client, asset.client
      assert_equal accessor, asset.accessor

      # basic attributes
      assert_equal record['id'], asset.id
      assert_equal record['title'], asset.title
      assert_equal record['assetCategory'], asset.asset_category
      assert_equal record['assetType'], asset.asset_type
      assert_equal record['assetSubType'], asset.asset_sub_type
      assert_equal record['lastModifiedDate'], asset.last_modified_date

      # links to other things
      assert_kind_of Hash, asset.links

      ['self', 'organization', 'locations'].each do |association|
        assert_link_for(asset, association)
      end
    end
  end

  describe '#attributes' do
    it 'converts properties back to an attributes hash' do
      asset = klass.new(client, record)
      attributes = asset.attributes

      assert_equal asset.id, attributes[:id]
      assert_equal asset.title, attributes[:title]
      assert_equal asset.asset_category, attributes[:asset_category]
      assert_equal asset.asset_type, attributes[:asset_type]
      assert_equal asset.asset_sub_type, attributes[:asset_sub_type]
    end
  end

  describe '#save' do
    it 'sends any recent updates to John Deere' do
      asset = klass.new(client, record)
      new_title = 'i REALLY like turtles!'

      asset.title = new_title
      assert_equal new_title, asset.title

      response = VCR.use_cassette('put_asset') { asset.save }
      assert_no_content response
    end

    it 'does not make a JD request if nothing has changed' do
      asset = klass.new(client, record)
      response = asset.save

      assert_nil response
    end

    it 'marks the record as saved' do
      asset = klass.new(client, record)
      asset.title = 'i REALLY like turtles!'

      response = VCR.use_cassette('put_asset') { asset.save }

      assert_equal 204, response.response.status
      assert_equal 'No Content', response.response.reason_phrase

      response = asset.save
      assert_nil response
    end
  end

  describe '#update' do
    it 'updates the attributes' do
      asset = klass.new(client, record)

      new_title = 'i REALLY like turtles!'
      VCR.use_cassette('put_asset') { asset.update(title: new_title) }

      assert_equal new_title, asset.title
      assert_equal new_title, asset.attributes[:title]
    end

    it 'sends the update to John Deere' do
      asset = klass.new(client, record)

      new_title = 'i REALLY like turtles!'
      response = VCR.use_cassette('put_asset') { asset.update(title: new_title) }

      assert_no_content response
    end
  end

  describe '#locations' do
    it 'returns a collection of locations for this asset' do
      organization = VCR.use_cassette('get_organizations') { client.organizations.first }
      asset = VCR.use_cassette('get_assets') { organization.assets.first }

      locations = VCR.use_cassette('get_asset_locations') do
        asset.locations.all
        asset.locations
      end

      assert_kind_of Array, locations.all

      locations.each do |location|
        assert_kind_of JD::Model::AssetLocation, location
      end
    end
  end
end