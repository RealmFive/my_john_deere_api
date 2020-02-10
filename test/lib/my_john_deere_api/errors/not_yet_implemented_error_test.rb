require 'support/helper'

describe 'MyJohnDeereApi::NotYetImplementedError' do
  it 'inherits from StandardError' do
    error = MyJohnDeereApi::NotYetImplementedError.new
    assert_kind_of StandardError, error
  end

  it 'has a default message' do
    error = MyJohnDeereApi::NotYetImplementedError.new
    assert_includes error.message, 'This is not yet implemented. View README to help make this gem better!'
  end
end