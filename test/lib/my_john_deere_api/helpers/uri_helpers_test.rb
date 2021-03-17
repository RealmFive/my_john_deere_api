require 'support/helper'

class UriHelpersHelperSample
  include JD::Helpers::UriHelpers

  def test
    'test'
  end
end

describe 'UriHelpers' do
  let(:object) { UriHelpersHelperSample.new }

  describe '#uri_path' do
    it 'extracts the path from the uri' do
      path = object.send(:uri_path, 'https://example.com/turtles')
      assert_equal '/turtles', path
    end

    it 'is a private method' do
      exception = assert_raises(NoMethodError) { object.uri_path('https://example.com/turtles')}
      assert_includes exception.message, 'private method'
    end
  end

  describe '#id_from_uri(uri, label)' do
    it 'extracts the id immediately following a given label' do
      uri = 'https://example.com/cows/123/pigs/456/turtles/789/birds/012'
      assert_equal '789', object.send(:id_from_uri, uri, 'turtles')
    end

    it 'accepts a symbol for the label' do
      uri = 'https://example.com/cows/123/pigs/456/turtles/789/birds/012'
      assert_equal '789', object.send(:id_from_uri, uri, :turtles)
    end

    it 'is a private method' do
      uri = 'https://example.com/cows/123/pigs/456/turtles/789/birds/012'

      exception = assert_raises(NoMethodError) { object.id_from_uri(uri, 'turtles') }
      assert_includes exception.message, 'private method'
    end
  end

  it "preserves the public nature of the including class's other methods" do
    assert_equal 'test', object.test
  end
end