require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Individual::Asset' do
  let(:asset_id) { '123' }
  let(:client) { JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET]) }
  let(:accessor) { VCR.use_cassette('catalog') { client.send(:accessor) } }
  let(:object) { JD::Request::Individual::Asset.new(accessor, asset_id) }

  inherits_from JD::Request::Individual::Base

  describe '#initialize(access_token, asset_id)' do
    it 'accepts an access token' do
      assert_equal accessor, object.accessor
    end

    it 'accepts asset_id as id' do
      assert_equal asset_id, object.id
    end
  end

  describe '#resource' do
    it 'returns /assets/<asset_id>' do
      assert_equal "/assets/#{asset_id}", object.resource
    end
  end

  describe '#object' do
    it 'returns all records' do
      asset = VCR.use_cassette('get_asset') { object.object }
      assert_kind_of JD::Model::Asset, asset
    end
  end
end