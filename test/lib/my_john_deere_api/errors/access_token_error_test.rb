require 'support/helper'

describe 'MyJohnDeereApi::AccessTokenError' do
  it 'inherits from StandardError' do
    error = MyJohnDeereApi::AccessTokenError.new
    assert_kind_of StandardError, error
  end

  it 'has a default message' do
    error = MyJohnDeereApi::AccessTokenError.new
    assert_includes error.message, 'Access Token must be supplied'
  end
end