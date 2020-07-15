require 'support/helper'

describe 'MyJohnDeereApi::MaxRetriesExceededError' do
  it 'inherits from StandardError' do
    error = MyJohnDeereApi::MaxRetriesExceededError.new(:get, '503')
    assert_kind_of StandardError, error
  end

  it 'accepts a request description, and includes in message' do
    message = MyJohnDeereApi::MaxRetriesExceededError.new(:get, '503 Service Unavailable').message
    assert_equal message, "Max retries (12) exceeded for GET request: 503 Service Unavailable"
  end
end