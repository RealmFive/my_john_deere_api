require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Collection::ContributionDefinitions' do
  let(:klass) { MyJohnDeereApi::Request::Collection::ContributionDefinitions }

  let(:collection) { klass.new(accessor, contribution_product: contribution_product_id) }
  let(:object) { collection }

  inherits_from JD::Request::Collection::Base

  describe '#initialize(access_token)' do
    it 'accepts an access token' do
      assert_kind_of OAuth::AccessToken, collection.accessor
    end

    it 'accepts associations' do
      collection = klass.new(accessor, something: 123)

      assert_kind_of Hash, collection.associations
      assert_equal 123, collection.associations[:something]
    end
  end

  describe '#resource' do
    it 'returns /contributionProducts/<contribution_product_id>/contributionDefinitions' do
      assert_equal "/contributionProducts/#{contribution_product_id}/contributionDefinitions", collection.resource
    end
  end

  describe '#all' do
    it 'returns all records' do
      all = VCR.use_cassette('get_contribution_definitions') { collection.all }

      assert_kind_of Array, all
      assert_equal collection.count, all.size

      all.each do |item|
        assert_kind_of JD::Model::ContributionDefinition, item
      end
    end
  end

  describe '#count' do
    let(:server_response) do
      contents = File.read('test/support/vcr/get_contribution_definitions.yml')
      body = YAML.load(contents)['http_interactions'].last['response']['body']['string']
      JSON.parse(body)
    end

    let(:server_count) { server_response['total'] }

    it 'returns the total count of records in the collection' do
      count = VCR.use_cassette('get_contribution_definitions') { collection.count }

      assert_equal server_count, count
    end
  end

  describe 'results' do
    let(:definition_names) do
      contents = File.read('test/support/vcr/get_contribution_definitions.yml')
      body = YAML.load(contents)['http_interactions'].last['response']['body']['string']

      JSON.parse(body)['values'].map{|v| v['name']}
    end

    it 'returns all records as a single enumerator' do
      count = VCR.use_cassette('get_contribution_definitions') { collection.count }
      names = VCR.use_cassette('get_contribution_definitions') { collection.map(&:name) }

      assert_kind_of Array, names
      assert_equal count, names.size

      definition_names.each do |expected_name|
        assert_includes names, expected_name
      end
    end
  end

  describe '#find(contribution_definition_id)' do
    it 'retrieves the asset' do
      definition = VCR.use_cassette('get_contribution_definition') { collection.find(contribution_definition_id) }
      assert_kind_of JD::Model::ContributionDefinition, definition
    end
  end
end