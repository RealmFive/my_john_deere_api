require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Individual::Base' do
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