require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Collection::ContributionProducts' do
  let(:klass) { MyJohnDeereApi::Request::Collection::ContributionProducts }
  let(:organization_id) do
    contents = File.read('test/support/vcr/get_organizations.yml')
    body = YAML.load(contents)['http_interactions'].first['response']['body']['string']
    JSON.parse(body)['values'].first['id']
  end

  let(:client) { JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET]) }
  let(:accessor) { VCR.use_cassette('catalog') { client.send(:accessor) } }
  let(:collection) { klass.new(accessor, organization: organization_id) }
  let(:object) { collection }

  inherits_from JD::Request::Collection::Base

  describe '#initialize(access_token)' do
    it 'accepts an access token' do
      assert_kind_of OAuth::AccessToken, collection.accessor
    end

    it 'accepts associations' do
      collection = klass.new(accessor, organization: '123')

      assert_kind_of Hash, collection.associations
      assert_equal '123', collection.associations[:organization]
    end
  end

  describe '#resource' do
    it 'returns /contributionProducts' do
      assert_equal "/contributionProducts?clientControlled=true", collection.resource
    end
  end

  describe '#all' do
    it 'returns all records' do
      all = VCR.use_cassette('get_contribution_products') { collection.all }

      assert_kind_of Array, all
      assert_equal collection.count, all.size

      all.each do |item|
        assert_kind_of JD::Model::ContributionProduct, item
      end
    end
  end

  describe '#count' do
    let(:server_response) do
      contents = File.read('test/support/vcr/get_contribution_products.yml')
      body = YAML.load(contents)['http_interactions'].first['response']['body']['string']
      JSON.parse(body)
    end

    let(:server_count) { server_response['total'] }

    it 'returns the total count of records in the collection' do
      count = VCR.use_cassette('get_contribution_products') { collection.count }

      assert_equal server_count, count
    end
  end

  describe 'results' do
    let(:product_names) do
      contents = File.read('test/support/vcr/get_contribution_products.yml')
      body = YAML.load(contents)['http_interactions'].first['response']['body']['string']

      JSON.parse(body)['values'].map{|v| v['marketPlaceName']}
    end

    it 'returns all records as a single enumerator' do
      count = VCR.use_cassette('get_contribution_products') { collection.count }
      names = VCR.use_cassette('get_contribution_products') { collection.map(&:market_place_name) }

      assert_kind_of Array, names
      assert_equal count, names.size

      product_names.each do |expected_name|
        assert_includes names, expected_name
      end
    end
  end

  describe '#find(contribution_product_id)' do
    let(:product_id) { '00000000-0000-0000-0000-000000000000' }

    it 'retrieves the asset' do
      product = VCR.use_cassette('get_contribution_product') { collection.find(product_id) }
      assert_kind_of JD::Model::ContributionProduct, product
    end
  end
end