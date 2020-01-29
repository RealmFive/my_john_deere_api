require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Individual::ContributionProduct' do
  let(:product_id) { '00000000-0000-0000-0000-000000000000' }
  let(:client) { JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET]) }
  let(:accessor) { VCR.use_cassette('catalog') { client.send(:accessor) } }
  let(:object) { JD::Request::Individual::ContributionProduct.new(accessor, product_id) }

  inherits_from JD::Request::Individual::Base

  describe '#initialize(access_token, asset_id)' do
    it 'accepts an access token' do
      assert_equal accessor, object.accessor
    end

    it 'accepts contribution_product_id as id' do
      assert_equal product_id, object.id
    end
  end

  describe '#resource' do
    it 'returns /contributionProducts/<product_id>' do
      assert_equal "/contributionProducts/#{product_id}", object.resource
    end
  end

  describe '#object' do
    it 'returns all records' do
      product = VCR.use_cassette('get_contribution_product') { object.object }
      assert_kind_of JD::Model::ContributionProduct, product
    end
  end
end