require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Individual::ContributionDefinition' do
  let(:object) { JD::Request::Individual::ContributionDefinition.new(client, contribution_definition_id) }

  inherits_from JD::Request::Individual::Base

  describe '#initialize(client, contribution_definition_id)' do
    it 'accepts a client' do
      assert_equal client, object.client
    end

    it 'accepts contribution_definition_id as id' do
      assert_equal contribution_definition_id, object.id
    end
  end

  describe '#resource' do
    it 'returns /platform/contributionDefinitions/<definition_id>' do
      assert_equal "/platform/contributionDefinitions/#{contribution_definition_id}", object.resource
    end
  end

  describe '#object' do
    it 'returns all records' do
      definition = VCR.use_cassette('get_contribution_definition') { object.object }
      assert_kind_of JD::Model::ContributionDefinition, definition
    end
  end
end