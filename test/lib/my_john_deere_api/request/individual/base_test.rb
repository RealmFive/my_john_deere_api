require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Individual::Base' do
  let(:asset_id) { '123' }
  let(:client) { JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET]) }
  let(:accessor) { VCR.use_cassette('catalog') { client.send(:accessor) } }
  let(:object) { JD::Request::Individual::Base.new(accessor, asset_id) }

  describe '#initialize(access_token, asset_id)' do
    it 'accepts an access token' do
      assert_equal accessor, object.accessor
    end

    it 'accepts asset_id as id' do
      assert_equal asset_id, object.id
    end
  end
end