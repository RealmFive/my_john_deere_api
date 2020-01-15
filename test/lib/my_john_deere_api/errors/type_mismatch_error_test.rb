require 'support/helper'

describe 'MyJohnDeereApi::TypeMismatchError' do
  it 'inherits from StandardError' do
    error = MyJohnDeereApi::TypeMismatchError.new
    assert_kind_of StandardError, error
  end

  it 'has a default message' do
    error = MyJohnDeereApi::TypeMismatchError.new
    assert_includes error.message, 'Record type does not match'
  end
end