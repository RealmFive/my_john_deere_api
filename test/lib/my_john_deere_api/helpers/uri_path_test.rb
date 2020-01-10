require 'support/helper'

class UriPathHelperSample
  include JD::Helpers::UriPath
end

describe 'UriPath' do
  let(:object) { UriPathHelperSample.new }

  it 'extracts the path from the uri' do
    path = object.send(:uri_path, 'https://example.com/turtles')
    assert_equal '/turtles', path
  end

  it 'removes leading /platform from the path' do
    path = object.send(:uri_path, 'https://example.com/platform/turtles')
    assert_equal '/turtles', path
  end

  it 'preserves /platform in any other part of the path' do
    path = object.send(:uri_path, 'https://example.com/platform/turtles/platform')
    assert_equal '/turtles/platform', path
  end

  it 'is a private method' do
    assert_raises(NoMethodError) { object.uri_path('https://example.com/turtles')}
  end
end