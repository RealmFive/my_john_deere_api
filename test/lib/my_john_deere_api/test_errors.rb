require 'support/helper'

describe 'MyJohnDeereApi Errors' do
  describe 'loading dependencies' do
    it 'loads AccessTokenError' do
      assert JD::AccessTokenError
    end
  end
end
