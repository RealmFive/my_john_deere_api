require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Collection::Assets' do
  let(:klass) { JD::Request::Collection::Assets }
  let(:collection) { klass.new(client, organization: organization_id) }
  let(:object) { collection }

  inherits_from JD::Request::Collection::Base

  describe '#initialize(client)' do
    it 'accepts a client' do
      assert_equal client, collection.client
    end

    it 'accepts associations' do
      collection = klass.new(client, organization: organization_id)

      assert_kind_of Hash, collection.associations
      assert_equal organization_id, collection.associations[:organization]
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
    it 'creates a new asset with the given attributes' do
      attributes = CONFIG.sanitized_asset_attributes
      object = VCR.use_cassette('post_assets') { collection.create(attributes) }

      assert_kind_of JD::Model::Asset, object
      assert_equal attributes[:title], object.title
      assert_equal attributes[:asset_category], object.asset_category
      assert_equal attributes[:asset_type], object.asset_type
      assert_equal attributes[:asset_sub_type], object.asset_sub_type
    end
  end

  describe '#find(asset_id)' do
    it 'retrieves the asset' do
      asset = VCR.use_cassette('get_asset') { collection.find(asset_id) }
      assert_kind_of JD::Model::Asset, asset
    end
  end

  describe '#count' do
    let(:server_response) do
      contents = File.read('test/support/vcr/get_assets.yml')
      body = YAML.load(contents)['http_interactions'].last['response']['body']['string']
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
      body = YAML.load(contents)['http_interactions'].last['response']['body']['string']
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