require 'support/helper'

describe 'MyJohnDeereApi::Model::Organization' do
  let(:klass) { JD::Model::Organization }

  let(:record) do
    {
      "@type"=>"Organization",
      "name"=>"Century Farms",
      "type"=>"customer",
      "member"=>true,
      "id"=>"123456",
      "links"=>[
        {"@type"=>"Link", "rel"=>"self", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}"},
        {"@type"=>"Link", "rel"=>"machines", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}/machines"},
        {"@type"=>"Link", "rel"=>"wdtCapableMachines", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}/machines?capability=wdt"},
        {"@type"=>"Link", "rel"=>"files", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}/files"},
        {"@type"=>"Link", "rel"=>"transferableFiles", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}/files?transferable=true"},
        {"@type"=>"Link", "rel"=>"uploadFile", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}/files"},
        {"@type"=>"Link", "rel"=>"sendFileToMachine", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}/fileTransfers"},
        {"@type"=>"Link", "rel"=>"addMachine", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}/machines"},
        {"@type"=>"Link", "rel"=>"addField", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}/fields"},
        {"@type"=>"Link", "rel"=>"assets", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}/assets"},
        {"@type"=>"Link", "rel"=>"fields", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}/fields"},
        {"@type"=>"Link", "rel"=>"farms", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}/farms"},
        {"@type"=>"Link", "rel"=>"boundaries", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}/boundaries"},
        {"@type"=>"Link", "rel"=>"clients", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}/clients"},
        {"@type"=>"Link", "rel"=>"controllers", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}/orgController"}
      ]
    }
  end

  describe '#initialize(record, client = nil)' do
    def link_for label
      record['links'].detect{|link| link['rel'] == label}['uri'].gsub('https://sandboxapi.deere.com/platform', '')
    end

    it 'sets the attributes from the given record' do
      organization = klass.new(record)

      # basic attributes
      assert_equal record['name'], organization.name
      assert_equal record['type'], organization.type
      assert_equal record['member'], organization.member?
      assert_equal record['id'], organization.id
      assert_nil organization.accessor

      # links to other things
      assert_kind_of Hash, organization.links

      ['fields', 'machines', 'files', 'assets', 'farms', 'boundaries', 'clients', 'controllers'].each do |association|
        assert_equal link_for(association), organization.links[association]
      end
    end

    it 'accepts an optional client' do
      organization = klass.new(record, client)
      assert_equal client, organization.client
    end
  end

  describe '#fields' do
    it 'returns a collection of fields for this organization' do
      organization = VCR.use_cassette('get_organizations') { client.organizations.first }
      fields = VCR.use_cassette('get_fields') { organization.fields.all }

      assert_kind_of Array, fields

      fields.each do |field|
        assert_kind_of JD::Model::Field, field
      end
    end

    it 'raises an exception if an accessor is not available' do
      organization = klass.new(record)

      exception = assert_raises(JD::AccessTokenError) { organization.fields }

      assert_includes exception.message, 'Access Token must be supplied'
    end
  end

  describe '#assets' do
    it 'returns a collection of assets for this organization' do
      organization = VCR.use_cassette('get_organizations') { client.organizations.first }
      assets = VCR.use_cassette('get_assets') { organization.assets.all; organization.assets }

      assert_kind_of JD::Request::Collection::Assets, assets

      assets.each do |assets|
        assert_kind_of JD::Model::Asset, assets
      end
    end

    it 'raises an exception if an accessor is not available' do
      organization = klass.new(record)

      exception = assert_raises(JD::AccessTokenError) { organization.assets }
      assert_includes exception.message, 'Access Token must be supplied'
    end
  end
end