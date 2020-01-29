require 'support/helper'

describe 'MyJohnDeereApi::Request::Collection' do
  describe 'loading dependencies' do
    it 'loads Request::Collection::Base' do
      assert JD::Request::Collection::Base
    end

    it 'loads Request::Collection::Assets' do
      assert JD::Request::Collection::Assets
    end

    it 'loads Request::Collection::AssetLocations' do
      assert JD::Request::Collection::AssetLocations
    end

    it 'loads Request::Collection::ContributionProducts' do
      assert JD::Request::Collection::ContributionProducts
    end

    it 'loads Request::Collection::Organizations' do
      assert JD::Request::Collection::Organizations
    end

    it 'loads Request::Collection::Fields' do
      assert JD::Request::Collection::Fields
    end

    it 'loads Request::Collection::Flags' do
      assert JD::Request::Collection::Flags
    end
  end
end
