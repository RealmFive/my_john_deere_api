require 'support/helper'

describe 'MyJohnDeereApi::Model::Field' do
  let(:record) do
    {
      "@type"=>"Field",
      "name"=>"Happy Field",
      "archived"=>false,
      "id"=>"123456",
      "links"=>[
        {"@type"=>"Link", "rel"=>"self", "uri"=>"https://sandboxapi.deere.com/platform/organizations/123456/fields/123456"},
        {"@type"=>"Link", "rel"=>"clients", "uri"=>"https://sandboxapi.deere.com/platform/organizations/123456/fields/123456/clients"},
        {"@type"=>"Link", "rel"=>"notes", "uri"=>"https://sandboxapi.deere.com/platform/organizations/123456/fields/123456/notes"},
      ]
    }
  end

  describe '#initialize' do
    def link_for label
      record['links'].detect{|link| link['rel'] == label}['uri'].gsub('https://sandboxapi.deere.com/platform', '')
    end

    it 'sets the attributes from the given record' do
      organization = JD::Model::Field.new(record)

      # basic attributes
      assert_equal record['name'], organization.name
      assert_equal record['archived'], organization.archived?
      assert_equal record['id'], organization.id

      # links to other things
      assert_kind_of Hash, organization.links

      ['clients', 'notes'].each do |association|
        assert_equal link_for(association), organization.links[association]
      end
    end
  end
end