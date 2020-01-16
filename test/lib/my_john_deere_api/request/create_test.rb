require 'support/helper'

describe 'MyJohnDeereApi::Request::Create' do
  describe 'loading dependencies' do
    it 'loads Request::Create::Base' do
      assert JD::Request::Create::Base
    end

    it 'loads Request::Create::Asset' do
      assert JD::Request::Create::Asset
    end

    it 'loads Request::Create::AssetLocation' do
      assert JD::Request::Create::AssetLocation
    end
  end
end
