require 'support/helper'

describe 'MyJohnDeereApi::InvalidRecordError' do
  it 'inherits from StandardError' do
    error = MyJohnDeereApi::InvalidRecordError.new
    assert_kind_of StandardError, error
  end

  it 'has a default message' do
    error = MyJohnDeereApi::InvalidRecordError.new
    assert_includes error.message, 'Record is invalid'
  end

  it 'accepts a hash of errors, and includes them in message' do
    errors = {
      name: 'must be specified',
      age: 'must be greater than 21'
    }

    message = MyJohnDeereApi::InvalidRecordError.new(errors).message

    assert_includes message, 'Record is invalid'
    assert_includes message, 'name must be specified'
    assert_includes message, 'age must be greater than 21'
  end
end