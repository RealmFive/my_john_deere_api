require 'support/helper'

class SampleModel < JD::Model::Base
  attr_reader :somefield

  def map_attributes(record)
    @somefield = record['somefield']
  end
end

describe 'MyJohnDeereApi::Model::Base' do
  let(:klass) { JD::Model::Base }
  let(:object) { klass.new(record, client) }

  let(:record) do
    {
      '@type'=>'Base',
      'id'=>'123',
      'somefield'=>'somevalue',
      "links"=>[
        {"@type"=>"Link", "rel"=>"self", "uri"=>"https://sandboxapi.deere.com/platform/assets/#{asset_id}"},
        {"@type"=>"Link", "rel"=>"organization", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}"},
        {"@type"=>"Link", "rel"=>"locations", "uri"=>"https://sandboxapi.deere.com/platform/assets/#{asset_id}/locations"},
      ]
    }
  end

  it 'includes UriHelpers' do
    assert_includes object.private_methods, :uri_path
    assert_includes object.private_methods, :id_from_uri
  end

  describe '#initialize(record, client)' do
    def link_for label
      record['links'].detect{|link| link['rel'] == label}['uri'].gsub('https://sandboxapi.deere.com/platform', '')
    end

    it 'raises an error if there is a record type mismatch' do
      record = {
        '@type'=>'WrongType',
        'links'=>[]
      }

      exception = assert_raises(JD::TypeMismatchError) { klass.new(record) }
      assert_equal "Expected record of type 'Base', but received type 'WrongType'", exception.message
    end

    it 'sets the base attributes' do
      assert_equal record['id'], object.id
      assert_equal record['@type'], object.record_type
      assert_equal client, object.client
    end

    it 'sets the links' do
      links = object.links

      assert_kind_of Hash, links

      ['self', 'organization', 'locations'].each do |link|
        assert_equal link_for(link), links[link]
      end
    end

    it 'maps additional fields in subclasses' do
      object = SampleModel.new(record)
      assert_equal 'somevalue', object.somefield
    end

    it 'does not require client' do
      object = klass.new(record)
      assert_nil object.client
    end
  end
end