require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Collection::Flags' do
  let(:collection) { JD::Request::Collection::Flags.new(accessor, organization: organization_id, field: field_id) }
  let(:object) { collection }

  inherits_from JD::Request::Collection::Base

  describe '#initialize(access_token)' do
    it 'accepts an access token' do
      assert_kind_of OAuth::AccessToken, collection.accessor
    end

    it 'accepts associations' do
      collection = JD::Request::Collection::Flags.new(accessor, organization: organization_id, field: field_id)

      assert_kind_of Hash, collection.associations
      assert_equal organization_id, collection.associations[:organization]
      assert_equal field_id, collection.associations[:field]
    end
  end

  describe '#resource' do
    it 'returns /organizations/{org_id}/fields/{field_id}/flags' do
      assert_equal "/organizations/#{organization_id}/fields/#{field_id}/flags", collection.resource
    end
  end

  describe '#all' do
    it 'returns all records' do
      all = VCR.use_cassette('get_flags') { collection.all }

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
      body = YAML.load(contents)['http_interactions'].last['response']['body']['string']
      JSON.parse(body)
    end

    let(:server_count) { server_response['total'] }

    it 'returns the total count of records in the collection' do
      count = VCR.use_cassette('get_flags') { collection.count }

      assert_equal server_count, count
    end
  end

  describe '#create(attributes)' do
    it 'raises an error, not yet implemented' do
      assert_raises(NotImplementedError) { collection.create({}) }
    end
  end

  describe '#find(id)' do
    it 'raises an error, not yet implemented' do
      assert_raises(NotImplementedError) { collection.find(123) }
    end
  end

  describe 'results' do
    let(:flag_geometries) do
      contents = File.read('test/support/vcr/get_flags.yml')
      body = YAML.load(contents)['http_interactions'].last['response']['body']['string']
      JSON.parse(body)['values'].map{|v| JSON.parse(v['geometry'])}
    end

    it 'returns all records as a single enumerator' do
      count = VCR.use_cassette('get_flags') { collection.count }
      geometries = VCR.use_cassette('get_flags') { collection.map{|item| item.geometry} }

      assert_kind_of Array, geometries
      assert_equal count, geometries.size

      flag_geometries.each do |expected_geometry|
        assert_includes geometries, expected_geometry
      end
    end
  end
end