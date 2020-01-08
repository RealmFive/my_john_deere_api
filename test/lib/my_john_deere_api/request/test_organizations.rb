require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Organizations' do
  let(:client) { JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET]) }
  let(:accessor) { VCR.use_cassette('catalog') { client.send(:accessor) } }
  let(:collection) { JD::Request::Organizations.new(accessor) }

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

  describe '#pagination' do
    it 'returns all records as a single enumerator' do
      expected_names = [
        'Century Farms', "JJ's Farm", 'Organization A', 'Organization B', 'Organization C',
        'Organization D', 'Organization E', 'Organization F', 'Organization G',
        'Organization H', 'Organization Eye', 'Organization Jay', 'Organization Kay',
        'Organization Elle'
      ]

      count = VCR.use_cassette('get_organizations') { collection.count }
      names = VCR.use_cassette('get_organizations', record: :new_episodes) { collection.map{|item| item.name} }

      assert_kind_of Array, names
      assert_equal count, names.size

      expected_names.each do |expected_name|
        assert_includes names, expected_name
      end
    end
  end
end