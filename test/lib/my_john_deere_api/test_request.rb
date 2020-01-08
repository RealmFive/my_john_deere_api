require 'support/helper'

describe 'MyJohnDeereApi::Request' do
  describe 'loading dependencies' do
    it 'loads Request::Collection' do
      assert JD::Request::Collection
    end

    it 'loads Request::Organizations' do
      assert JD::Request::Organizations
    end
  end
end
