require 'support/helper'

describe 'MyJohnDeereApi::UnsupportedEnvironmentError' do
  it 'inherits from StandardError' do
    error = MyJohnDeereApi::UnsupportedEnvironmentError.new
    assert_kind_of StandardError, error
  end

  it 'has a default message' do
    error = MyJohnDeereApi::UnsupportedEnvironmentError.new
    assert_includes error.message, 'This environment is not supported.'
  end

  it 'specifies the failing environment if supplied' do
    error = MyJohnDeereApi::UnsupportedEnvironmentError.new(:turtles)
    assert_includes error.message, "The :turtles environment is not supported."
  end
end