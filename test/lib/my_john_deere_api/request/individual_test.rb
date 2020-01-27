require 'support/helper'

describe 'MyJohnDeereApi::Request::Individual' do
  describe 'loading dependencies' do
    it 'loads Request::Individual::Base' do
      assert JD::Request::Individual::Base
    end

    it 'loads Request::Individual::Asset' do
      assert JD::Request::Individual::Asset
    end
  end
end
