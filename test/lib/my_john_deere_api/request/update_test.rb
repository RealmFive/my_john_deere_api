require 'support/helper'

describe 'MyJohnDeereApi::Request::Update' do
  describe 'loading dependencies' do
    it 'loads Request::Update::Base' do
      assert JD::Request::Update::Base
    end

    it 'loads Request::Update::Asset' do
      assert JD::Request::Update::Asset
    end
  end
end