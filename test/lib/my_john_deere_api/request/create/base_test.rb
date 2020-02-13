require 'support/helper'

describe 'MyJohnDeereApi::Request::Create::Base' do
  let(:attributes) { {} }

  describe '#initialize(access_token, attributes)' do
    it 'accepts an accessor and attributes' do
      object = JD::Request::Create::Base.new(accessor, attributes)

      assert_equal accessor, object.accessor
      assert_equal attributes, object.attributes
    end
  end

  describe '#headers' do
    it 'sets the accept and content-type headers' do
      object = JD::Request::Create::Base.new(accessor, attributes)
      headers = object.send(:headers)

      expected = 'application/vnd.deere.axiom.v3+json'

      assert_kind_of Hash, headers
      assert_equal expected, headers['Accept']
      assert_equal expected, headers['Content-Type']
    end
  end
end