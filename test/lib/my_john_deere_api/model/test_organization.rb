require 'support/helper'

describe 'MyJohnDeereApi::Model::Organization' do
  let(:record) do
    {
      "@type"=>"Organization",
      "name"=>"Century Farms",
      "type"=>"customer",
      "member"=>true,
      "id"=>"123456",
      "links"=>[
        {"@type"=>"Link", "rel"=>"self", "uri"=>"https://sandboxapi.deere.com/platform/organizations/123456"},
        {"@type"=>"Link", "rel"=>"machines", "uri"=>"https://sandboxapi.deere.com/platform/organizations/123456/machines"},
        {"@type"=>"Link", "rel"=>"wdtCapableMachines", "uri"=>"https://sandboxapi.deere.com/platform/organizations/123456/machines?capability=wdt"},
        {"@type"=>"Link", "rel"=>"files", "uri"=>"https://sandboxapi.deere.com/platform/organizations/123456/files"},
        {"@type"=>"Link", "rel"=>"transferableFiles", "uri"=>"https://sandboxapi.deere.com/platform/organizations/123456/files?transferable=true"},
        {"@type"=>"Link", "rel"=>"uploadFile", "uri"=>"https://sandboxapi.deere.com/platform/organizations/123456/files"},
        {"@type"=>"Link", "rel"=>"sendFileToMachine", "uri"=>"https://sandboxapi.deere.com/platform/organizations/123456/fileTransfers"},
        {"@type"=>"Link", "rel"=>"addMachine", "uri"=>"https://sandboxapi.deere.com/platform/organizations/123456/machines"},
        {"@type"=>"Link", "rel"=>"addField", "uri"=>"https://sandboxapi.deere.com/platform/organizations/123456/fields"},
        {"@type"=>"Link", "rel"=>"assets", "uri"=>"https://sandboxapi.deere.com/platform/organizations/123456/assets"},
        {"@type"=>"Link", "rel"=>"fields", "uri"=>"https://sandboxapi.deere.com/platform/organizations/123456/fields"},
        {"@type"=>"Link", "rel"=>"farms", "uri"=>"https://sandboxapi.deere.com/platform/organizations/123456/farms"},
        {"@type"=>"Link", "rel"=>"boundaries", "uri"=>"https://sandboxapi.deere.com/platform/organizations/123456/boundaries"},
        {"@type"=>"Link", "rel"=>"clients", "uri"=>"https://sandboxapi.deere.com/platform/organizations/123456/clients"},
        {"@type"=>"Link", "rel"=>"controllers", "uri"=>"https://sandboxapi.deere.com/platform/organizations/123456/orgController"}
      ]
    }
  end

  describe '#initialize' do
    def link_for label
      record['links'].detect{|link| link['rel'] == label}['uri']
    end

    it 'sets the attributes from the given record' do
      organization = JD::Model::Organization.new(record)

      # basic attributes
      assert_equal record['name'], organization.name
      assert_equal record['type'], organization.type
      assert_equal record['member'], organization.member?
      assert_equal record['id'], organization.id

      # links to other things
      assert_kind_of Hash, organization.links

      ['fields', 'machines', 'files', 'assets', 'farms', 'boundaries', 'clients', 'controllers'].each do |association|
        assert_equal link_for(association), organization.links[association]
      end
    end
  end
end