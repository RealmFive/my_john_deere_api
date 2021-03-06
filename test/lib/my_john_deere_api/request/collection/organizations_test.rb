require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Collection::Organizations' do
  let(:klass) { JD::Request::Collection::Organizations }
  let(:collection) { klass.new(client) }
  let(:object) { collection }

  inherits_from JD::Request::Collection::Base

  describe '#initialize(client)' do
    it 'accepts a client' do
      assert_equal client, collection.client
    end
  end

  describe '#resource' do
    it 'returns /platform/organization' do
      assert_equal '/platform/organizations', collection.resource
    end
  end

  describe '#all' do
    it 'returns all records' do
      all = VCR.use_cassette('get_organizations') { collection.all }

      assert_kind_of Array, all
      assert_equal collection.count, all.size

      all.each do |item|
        assert_kind_of JD::Model::Organization, item
      end
    end
  end

  describe '#find(organization_id)' do
    it 'retrieves the asset' do
      organization = VCR.use_cassette('get_organization') { collection.find(organization_id) }
      assert_kind_of JD::Model::Organization, organization
    end
  end

  describe '#count' do
    let(:server_response) do
      contents = File.read('test/support/vcr/get_organizations.yml')
      body = YAML.load(contents)['http_interactions'].last['response']['body']['string']
      JSON.parse(body)
    end

    let(:server_count) { server_response['total'] }

    it 'returns the total count of records in the collection' do
      count = VCR.use_cassette('get_organizations') { collection.count }

      assert_equal server_count, count
    end
  end

  describe 'pagination' do
    let(:organization_names) do
      contents = File.read('test/support/vcr/get_organizations.yml')
      body = YAML.load(contents)['http_interactions'].last['response']['body']['string']
      JSON.parse(body)['values'].map{|v| v['name']}
    end

    it 'returns all records as a single enumerator' do
      count = VCR.use_cassette('get_organizations') { collection.count }
      names = VCR.use_cassette('get_organizations') { collection.map{|item| item.name} }

      assert_kind_of Array, names
      assert_equal count, names.size

      organization_names.each do |expected_name|
        assert_includes names, expected_name
      end
    end

    it 'passes the client to all organizations' do
      organizations = VCR.use_cassette('get_organizations') { collection.all }

      organizations.each do |organization|
        assert_equal client, organization.client
      end
    end
  end
end