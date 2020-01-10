require 'support/helper'

describe 'MyJohnDeereApi::Helpers' do
  describe 'loading dependencies' do
    it 'loads Helpers::UriHelpers' do
      assert JD::Helpers::UriHelpers
    end

    it 'loads Helpers::CaseConversion' do
      assert JD::Helpers::CaseConversion
    end
  end
end
