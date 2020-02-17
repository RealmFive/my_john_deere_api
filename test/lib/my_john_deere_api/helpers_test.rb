require 'support/helper'

describe 'MyJohnDeereApi::Helpers' do
  describe 'loading dependencies' do
    it 'loads Helpers::UriHelpers' do
      assert JD::Helpers::UriHelpers
    end

    it 'loads Helpers::CaseConversion' do
      assert JD::Helpers::CaseConversion
    end

    it 'loads Helpers::EnvironmentHelper' do
      assert JD::Helpers::EnvironmentHelper
    end

    it 'loads Helpers::ValidateContributionDefinition' do
      assert JD::Helpers::ValidateContributionDefinition
    end
  end
end
