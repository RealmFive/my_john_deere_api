require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Individual::Base' do
  let(:object) { JD::Request::Individual::Base.new(client, asset_id) }

  describe '#initialize(client, asset_id)' do
    it 'accepts a client' do
      assert_equal client, object.client
    end

    it 'accepts asset_id as id' do
      assert_equal asset_id, object.id
    end
  end
end