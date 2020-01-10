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

  let(:client) { JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET]) }
  let(:accessor) { VCR.use_cassette('catalog') { client.send(:accessor) } }

  describe '#initialize' do
    def link_for label
      record['links'].detect{|link| link['rel'] == label}['uri'].gsub('https://sandboxapi.deere.com/platform', '')
    end

    it 'sets the attributes from the given record' do
      field = JD::Model::Field.new(record)

      assert_nil field.accessor

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

    it 'accepts an optional accessor' do
      accessor = 'mock-accessor'

      field = JD::Model::Field.new(record, accessor)
      assert_equal accessor, field.accessor
    end
  end

  describe '#flags' do
    it 'returns a collection of flags for this organization' do
      accessor
      organization = VCR.use_cassette('get_organizations') { client.organizations.first }
      field = VCR.use_cassette('get_fields') { organization.fields.first }
      flags = VCR.use_cassette('get_flags') { field.flags }

      assert_kind_of Array, flags

      flags.each do |flag|
        assert_kind_of JD::Model::Flag, flag
      end
    end

    it 'raises an exception if an accessor is not available' do
      field = JD::Model::Field.new(record)

      exception = assert_raises(JD::AccessTokenError) { field.flags }

      assert_includes exception.message, 'Access Token must be supplied'
    end
  end
end