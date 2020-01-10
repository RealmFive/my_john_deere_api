require 'support/helper'

describe 'MyJohnDeereApi::Model::Asset' do
  let(:record) do
    {
      "@type"=>"ContributedAsset",
      "title"=>"Happy Device",
      "assetCategory"=>"DEVICE",
      "assetType"=>"SENSOR",
      "assetSubType"=>"OTHER",
      "id"=>"123456",
      "lastModifiedDate"=>"2018-01-31T20:36:16.727Z",
      "links"=>[
        {"@type"=>"Link", "rel"=>"self", "uri"=>"https://sandboxapi.deere.com/platform/assets/123456"},
        {"@type"=>"Link", "rel"=>"organization", "uri"=>"https://sandboxapi.deere.com/platform/organizations/234567"},
        {"@type"=>"Link", "rel"=>"locations", "uri"=>"https://sandboxapi.deere.com/platform/assets/123456/locations"},
      ]
    }
  end

  let(:client) { JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET]) }
  let(:accessor) { VCR.use_cassette('catalog') { client.send(:accessor) } }

  describe '#initialize' do
    def link_for label
      record['links'].detect{|link| link['rel'] == label}['uri'].gsub('https://sandboxapi.deere.com/platform', '')
    end

    it 'sets the attributes from the given record' do
      asset = JD::Model::Asset.new(record)

      assert_nil asset.accessor

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
        assert_equal link_for(association), asset.links[association]
      end
    end

    it 'accepts an optional accessor' do
      accessor = 'mock-accessor'

      asset = JD::Model::Asset.new(record, accessor)
      assert_equal accessor, asset.accessor
    end
  end
end