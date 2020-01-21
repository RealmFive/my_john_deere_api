require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Collection::Organizations' do
  let(:client) { JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET]) }
  let(:accessor) { VCR.use_cassette('catalog') { client.send(:accessor) } }
  let(:collection) { JD::Request::Collection::Organizations.new(accessor) }
  let(:object) { collection }

  inherits_from JD::Request::Collection::Base

  describe '#initialize(access_token)' do
    it 'accepts an access token' do
      assert_kind_of OAuth::AccessToken, collection.accessor
    end
  end

  describe '#resource' do
    it 'returns /organization' do
      assert_equal '/organizations', collection.resource
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

  describe '#count' do
    let(:server_response) do
      contents = File.read('test/support/vcr/get_organizations.yml')
      body = YAML.load(contents)['http_interactions'].first['response']['body']['string']
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
      body = YAML.load(contents)['http_interactions'].first['response']['body']['string']
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

    it 'passes the accessor to all organizations' do
      organizations = VCR.use_cassette('get_organizations') { collection.all }

      organizations.each do |organization|
        assert_equal accessor, organization.accessor
      end
    end
  end
end