require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Individual::Organization' do
  let(:object) { JD::Request::Individual::Organization.new(client, organization_id) }

  inherits_from JD::Request::Individual::Base

  describe '#initialize(client, asset_id)' do
    it 'accepts a client' do
      assert_equal client, object.client
    end

    it 'accepts organization_id as id' do
      assert_equal organization_id, object.id
    end
  end

  describe '#resource' do
    it 'returns /platform/organizations/<organization_id>' do
      assert_equal "/platform/organizations/#{organization_id}", object.resource
    end
  end

  describe '#object' do
    it 'returns all records' do
      organization = VCR.use_cassette('get_organization') { object.object }
      assert_kind_of JD::Model::Organization, organization
    end
  end
end