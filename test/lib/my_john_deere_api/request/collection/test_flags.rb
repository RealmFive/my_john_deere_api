require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Collection::Flags' do
  let(:organization_id) do
    contents = File.read('test/support/vcr/get_organizations.yml')
    body = YAML.load(contents)['http_interactions'].first['response']['body']['string']
    JSON.parse(body)['values'].first['id']
  end

  let(:field_id) do
    contents = File.read('test/support/vcr/get_fields.yml')
    body = YAML.load(contents)['http_interactions'].first['response']['body']['string']
    JSON.parse(body)['values'].first['id']
  end

  let(:client) { JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET]) }
  let(:accessor) { VCR.use_cassette('catalog') { client.send(:accessor) } }
  let(:collection) { JD::Request::Collection::Flags.new(accessor, organization: organization_id, field: field_id) }

  describe '#initialize(access_token)' do
    it 'accepts an access token' do
      assert_kind_of OAuth::AccessToken, collection.accessor
    end

    it 'accepts associations' do
      collection = JD::Request::Collection::Flags.new(accessor, organization: '123', field: '456')

      assert_kind_of Hash, collection.associations
      assert_equal '123', collection.associations[:organization]
      assert_equal '456', collection.associations[:field]
    end
  end

  describe '#resource' do
    it 'returns /organizations/{org_id}/fields/{field_id}/flags' do
      assert_equal "/organizations/#{organization_id}/fields/#{field_id}/flags", collection.resource
    end
  end

  describe '#all' do
    it 'returns all records' do
      all = VCR.use_cassette('get_flags', record: :new_episodes) { collection.all }

      assert_kind_of Array, all
      assert_equal collection.count, all.size

      all.each do |item|
        assert_kind_of JD::Model::Flag, item
      end
    end
  end

  describe '#count' do
    let(:server_response) do
      contents = File.read('test/support/vcr/get_flags.yml')
      body = YAML.load(contents)['http_interactions'].first['response']['body']['string']
      JSON.parse(body)
    end

    let(:server_count) { server_response['total'] }

    it 'returns the total count of records in the collection' do
      count = VCR.use_cassette('get_flags') { collection.count }

      assert_equal server_count, count
    end
  end

  describe 'results' do
    let(:flag_geometries) do
      contents = File.read('test/support/vcr/get_flags.yml')
      body = YAML.load(contents)['http_interactions'].first['response']['body']['string']
      JSON.parse(body)['values'].map{|v| JSON.parse(v['geometry'])}
    end

    it 'returns all records as a single enumerator' do
      count = VCR.use_cassette('get_flags') { collection.count }
      geometries = VCR.use_cassette('get_flags', record: :new_episodes) { collection.map{|item| item.geometry} }

      assert_kind_of Array, geometries
      assert_equal count, geometries.size

      flag_geometries.each do |expected_geometry|
        assert_includes geometries, expected_geometry
      end
    end
  end
end