require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Collection::Assets' do
  let(:organization_id) do
    contents = File.read('test/support/vcr/get_organizations.yml')
    body = YAML.load(contents)['http_interactions'].first['response']['body']['string']
    JSON.parse(body)['values'].first['id']
  end

  let(:client) { JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET]) }
  let(:accessor) { VCR.use_cassette('catalog') { client.send(:accessor) } }
  let(:collection) { JD::Request::Collection::Assets.new(accessor, organization: organization_id) }
  let(:object) { collection }

  inherits_from JD::Request::Collection::Base

  describe '#initialize(access_token)' do
    it 'accepts an access token' do
      assert_kind_of OAuth::AccessToken, collection.accessor
    end

    it 'accepts associations' do
      collection = JD::Request::Collection::Assets.new(accessor, organization: '123')

      assert_kind_of Hash, collection.associations
      assert_equal '123', collection.associations[:organization]
    end
  end

  describe '#resource' do
    it 'returns /organizations/{org_id}/assets' do
      assert_equal "/organizations/#{organization_id}/assets", collection.resource
    end
  end

  describe '#all' do
    it 'returns all records' do
      all = VCR.use_cassette('get_assets') { collection.all }

      assert_kind_of Array, all
      assert_equal collection.count, all.size

      all.each do |item|
        assert_kind_of JD::Model::Asset, item
      end
    end
  end

  describe '#create(attributes)' do
    let(:title) { 'i like turtles' }
    let(:category) { 'DEVICE' }
    let(:type) { 'SENSOR' }
    let(:subtype) { 'ENVIRONMENTAL' }

    it 'creates a new asset with the given attributes' do
      attributes = {
        contribution_definition_id: ENV['CONTRIBUTION_DEFINITION_ID'],
        title: title,
        asset_category: category,
        asset_type: type,
        asset_sub_type: subtype
      }

      object = VCR.use_cassette('post_assets') { collection.create(attributes) }

      assert_kind_of JD::Model::Asset, object
      assert_equal title, object.title
      assert_equal category, object.asset_category
      assert_equal type, object.asset_type
      assert_equal subtype, object.asset_sub_type
    end
  end

  describe '#count' do
    let(:server_response) do
      contents = File.read('test/support/vcr/get_assets.yml')
      body = YAML.load(contents)['http_interactions'].first['response']['body']['string']
      JSON.parse(body)
    end

    let(:server_count) { server_response['total'] }

    it 'returns the total count of records in the collection' do
      count = VCR.use_cassette('get_assets') { collection.count }

      assert_equal server_count, count
    end
  end

  describe 'results' do
    let(:asset_titles) do
      contents = File.read('test/support/vcr/get_assets.yml')
      body = YAML.load(contents)['http_interactions'].first['response']['body']['string']
      JSON.parse(body)['values'].map{|v| v['title']}
    end

    it 'returns all records as a single enumerator' do
      count = VCR.use_cassette('get_assets') { collection.count }
      titles = VCR.use_cassette('get_assets') { collection.map(&:title) }

      assert_kind_of Array, titles
      assert_equal count, titles.size

      asset_titles.each do |expected_title|
        assert_includes titles, expected_title
      end
    end
  end
end