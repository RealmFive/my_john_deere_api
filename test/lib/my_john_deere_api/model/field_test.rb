require 'support/helper'

describe 'MyJohnDeereApi::Model::Field' do
  let(:klass) { JD::Model::Field }

  let(:record) do
    {
      "@type"=>"Field",
      "name"=>"Happy Field",
      "archived"=>false,
      "id"=>"123456",
      "links"=>[
        {"@type"=>"Link", "rel"=>"self", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}/fields/#{field_id}"},
        {"@type"=>"Link", "rel"=>"clients", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}/fields/#{field_id}/clients"},
        {"@type"=>"Link", "rel"=>"notes", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}/fields/#{field_id}/notes"},
      ]
    }
  end

  describe '#initialize' do
    def link_for label
      record['links'].detect{|link| link['rel'] == label}['uri'].gsub('https://sandboxapi.deere.com/platform', '')
    end

    it 'sets the attributes from the given record' do
      field = klass.new(client, record)

      assert_equal client, field.client
      assert_equal accessor, field.accessor

      # basic attributes
      assert_equal record['name'], field.name
      assert_equal record['archived'], field.archived?
      assert_equal record['id'], field.id

      # links to other things
      assert_kind_of Hash, field.links

      ['clients', 'notes'].each do |association|
        assert_equal link_for(association), field.links[association]
      end
    end
  end

  describe '#flags' do
    it 'returns a collection of flags for this organization' do
      organization = VCR.use_cassette('get_organizations') { client.organizations.first }
      field = VCR.use_cassette('get_fields') { organization.fields.first }
      flags = VCR.use_cassette('get_flags') { field.flags.all }

      assert_kind_of Array, flags

      flags.each do |flag|
        assert_kind_of JD::Model::Flag, flag
      end
    end
  end

  describe 'private #organization_id' do
    it "infers the organization_id from links" do
      field = klass.new(client, record)
      assert_equal organization_id, field.send(:organization_id)
    end
  end
end