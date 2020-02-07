require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Individual::ContributionProduct' do
  let(:object) { JD::Request::Individual::ContributionProduct.new(accessor, contribution_product_id) }

  inherits_from JD::Request::Individual::Base

  describe '#initialize(access_token, contribution_product_id)' do
    it 'accepts an access token' do
      assert_equal accessor, object.accessor
    end

    it 'accepts contribution_product_id as id' do
      assert_equal contribution_product_id, object.id
    end
  end

  describe '#resource' do
    it 'returns /contributionProducts/<product_id>' do
      assert_equal "/contributionProducts/#{contribution_product_id}", object.resource
    end
  end

  describe '#object' do
    it 'returns all records' do
      product = VCR.use_cassette('get_contribution_product') { object.object }
      assert_kind_of JD::Model::ContributionProduct, product
    end
  end
end