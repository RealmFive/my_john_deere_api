require 'support/helper'

describe 'MyJohnDeereApi::Request' do
  describe 'loading dependencies' do
    it 'loads Request::Base' do
      assert JD::Request::Base
    end

    it 'loads Request::Organizations' do
      assert JD::Request::Organizations
    end
  end
end
