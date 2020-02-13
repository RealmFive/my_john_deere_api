require 'support/helper'

describe 'MyJohnDeereApi::Validators' do
  describe 'loading dependencies' do
    it 'loads Validators::Base' do
      assert JD::Validators::Base
    end

    it 'loads Validators::Asset' do
      assert JD::Validators::Asset
    end

    it 'loads Validators::AssetLocation' do
      assert JD::Validators::AssetLocation
    end
  end
end
