require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Individual::Asset' do
  let(:object) { JD::Request::Individual::Asset.new(client, asset_id) }

  inherits_from JD::Request::Individual::Base

  describe '#initialize(client, asset_id)' do
    it 'accepts a client' do
      assert_equal client, object.client
    end

    it 'accepts asset_id as id' do
      assert_equal asset_id, object.id
    end
  end

  describe '#resource' do
    it 'returns /platform/assets/<asset_id>' do
      assert_equal "/platform/assets/#{asset_id}", object.resource
    end
  end

  describe '#object' do
    it 'returns all records' do
      asset = VCR.use_cassette('get_asset') { object.object }
      assert_kind_of JD::Model::Asset, asset
    end
  end
end