require 'support/helper'

describe 'MyJohnDeereApi::MissingContributionDefinitionIdError' do
  let(:klass) { MyJohnDeereApi::MissingContributionDefinitionIdError }
  let(:error) { klass.new }

  it 'inherits from StandardError' do
    assert_kind_of StandardError, error
  end

  it 'has a default message' do
    assert_includes error.message, 'Contribution Definition ID must be set in the client to use this feature.'
  end
end