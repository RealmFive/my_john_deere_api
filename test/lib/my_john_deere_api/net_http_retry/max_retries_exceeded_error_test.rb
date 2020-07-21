require 'support/helper'

describe 'JD::NetHttpRetry::MaxRetriesExceededError' do
  it 'inherits from StandardError' do
    error = JD::NetHttpRetry::MaxRetriesExceededError.new(:get, '503')
    assert_kind_of StandardError, error
  end

  it 'accepts a request description, and includes in message' do
    message = JD::NetHttpRetry::MaxRetriesExceededError.new(:get, '503 Service Unavailable').message
    assert_equal message, "Max retries exceeded for GET request: 503 Service Unavailable"
  end
end