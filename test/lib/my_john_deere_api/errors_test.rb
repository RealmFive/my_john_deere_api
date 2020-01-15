require 'support/helper'

describe 'MyJohnDeereApi Errors' do
  describe 'loading dependencies' do
    it 'loads AccessTokenError' do
      assert JD::AccessTokenError
    end

    it 'loads TypeMismatchError' do
      assert JD::TypeMismatchError
    end
  end
end
