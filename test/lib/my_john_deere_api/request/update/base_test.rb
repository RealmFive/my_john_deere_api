require 'support/helper'
require 'yaml'
require 'json'

describe 'MyJohnDeereApi::Request::Update::Base' do
  let(:object) { JD::Request::Update::Base.new(accessor, item, attributes) }
  let(:item) { 'item' }
  let(:attributes) { {} }

  describe '#initialize(access_token, item, attributes)' do
    it 'accepts an accessor, item and attributes' do
      object = JD::Request::Update::Base.new(accessor, item, attributes)

      assert_equal accessor, object.accessor
      assert_equal item, object.item
      assert_equal attributes, object.attributes
    end

    it 'creates an empty error hash' do
      object = JD::Request::Update::Base.new(accessor, item, {})
      assert_equal({}, object.errors)
    end
  end

  describe '#headers' do
    it 'sets the accept and content-type headers' do
      object = JD::Request::Update::Base.new(accessor, item, attributes)
      headers = object.send(:headers)

      expected = 'application/vnd.deere.axiom.v3+json'

      assert_kind_of Hash, headers
      assert_equal expected, headers['Accept']
      assert_equal expected, headers['Content-Type']
    end
  end
end