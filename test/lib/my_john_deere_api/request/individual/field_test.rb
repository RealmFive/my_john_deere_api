require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Individual::Field' do
  let(:object) { JD::Request::Individual::Field.new(client, field_id, organization: organization_id) }

  inherits_from JD::Request::Individual::Base

  describe '#initialize(client, organization_id, field_id)' do
    it 'accepts a client' do
      assert_equal client, object.client
    end

    it 'accepts organization_id as organization_id' do
      assert_equal organization_id, object.associations[:organization]
    end

    it 'accepts field_id as id' do
      assert_equal field_id, object.id
    end
  end

  describe '#resource' do
    it 'returns /platform/organizations/<organization_id>/fields/<field_id>' do
      assert_equal "/platform/organizations/#{organization_id}/fields/#{field_id}", object.resource
    end
  end

  describe '#object' do
    it 'returns all records' do
      field = VCR.use_cassette('get_field') { object.object }
      assert_kind_of JD::Model::Field, field
    end
  end
end