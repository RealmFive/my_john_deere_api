require 'support/helper'

class ValidateContributionDefinitionHelperSample
  include JD::Helpers::ValidateContributionDefinition

  attr_reader :client

  def initialize(client)
    @client = client
  end
end

describe 'Helpers::ValidateContributionDefinition' do
  let(:object) { ValidateContributionDefinitionHelperSample.new(client) }

  describe '#validate_contribution_definition' do
    it 'returns true when contribution_definition_id is present' do
      assert object.send(:validate_contribution_definition)
    end

    it 'raises an error when contribution_definition_id is missing' do
      client.contribution_definition_id = nil

      assert_raises(JD::MissingContributionDefinitionIdError) do
        object.send(:validate_contribution_definition)
      end
    end
  end

  # describe '#uri_path' do
  #   it 'extracts the path from the uri' do
  #     path = object.send(:uri_path, 'https://example.com/turtles')
  #     assert_equal '/turtles', path
  #   end
  #
  #   it 'removes leading /platform from the path' do
  #     path = object.send(:uri_path, 'https://example.com/platform/turtles')
  #     assert_equal '/turtles', path
  #   end
  #
  #   it 'preserves /platform in any other part of the path' do
  #     path = object.send(:uri_path, 'https://example.com/platform/turtles/platform')
  #     assert_equal '/turtles/platform', path
  #   end
  #
  #   it 'is a private method' do
  #     exception = assert_raises(NoMethodError) { object.uri_path('https://example.com/turtles')}
  #     assert_includes exception.message, 'private method'
  #   end
  # end
  #
  # describe '#id_from_uri(uri, label)' do
  #   it 'extracts the id immediately following a given label' do
  #     uri = 'https://example.com/cows/123/pigs/456/turtles/789/birds/012'
  #     assert_equal '789', object.send(:id_from_uri, uri, 'turtles')
  #   end
  #
  #   it 'accepts a symbol for the label' do
  #     uri = 'https://example.com/cows/123/pigs/456/turtles/789/birds/012'
  #     assert_equal '789', object.send(:id_from_uri, uri, :turtles)
  #   end
  #
  #   it 'is a private method' do
  #     uri = 'https://example.com/cows/123/pigs/456/turtles/789/birds/012'
  #
  #     exception = assert_raises(NoMethodError) { object.id_from_uri(uri, 'turtles') }
  #     assert_includes exception.message, 'private method'
  #   end
  # end
  #
  # it "preserves the public nature of the including class's other methods" do
  #   assert_equal 'test', object.test
  # end
end