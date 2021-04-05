require 'support/helper'

describe 'MyJohnDeereApi::Model::Organization' do
  include JD::LinkHelpers

  let(:klass) { JD::Model::Organization }
  let(:object) { klass.new(client, record) }

  let(:record) do
    {
      "@type"=>"Organization",
      "name"=>"Century Farms",
      "type"=>"customer",
      "member"=>true,
      "id"=>"123456",
      "links"=> links,
    }
  end

  let(:links) do
    [
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
  end

  let(:connections_link) do
    {
      "@type"=>"Link",
      "rel"=>"connections",
      "uri"=>"https://connections.deere.com/connections/johndeere-0000000000000000000000000000000000000000/organizations"
    }
  end

  describe '#initialize(record, client = nil)' do
    it 'sets the attributes from the given record' do
      assert_equal client, object.client
      assert_equal accessor, object.accessor

      # basic attributes
      assert_equal record['name'], object.name
      assert_equal record['type'], object.type
      assert_equal record['member'], object.member?
      assert_equal record['id'], object.id

      # links to other things
      assert_kind_of Hash, object.links

      ['fields', 'machines', 'files', 'assets', 'farms', 'boundaries', 'clients', 'controllers'].each do |association|
        assert_link_for(object, association)
      end
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
  end

  describe '#needs_connection?' do
    subject { object.needs_connection? }

    describe 'when user needs to connect organization within JD platform' do
      let(:links) { [connections_link] }

      it 'returns true' do
        assert subject
      end
    end

    describe "when user doesn't need to connect org" do
      it 'returns false' do
        refute subject
      end
    end
  end

  describe '#connections_uri' do
    subject { object.connections_uri }

    describe 'when user needs to connect organization within JD platform' do
      let(:links) { [connections_link] }

      it 'returns the URI for JD connections' do
        assert_includes subject, 'https://connections.deere.com/connections'
      end
    end

    describe "when user doesn't need to connect org" do
      it 'returns nil' do
        assert_nil subject
      end
    end
  end
end