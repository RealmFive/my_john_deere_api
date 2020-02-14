require 'support/helper'

describe 'MyJohnDeereApi::Request::Create::Base' do
  let(:klass) { JD::Request::Create::Base }
  let(:attributes) { {} }

  describe '#initialize(client, attributes)' do
    it 'accepts a client and attributes' do
      object = klass.new(client, attributes)

      assert_equal client, object.client
      assert_equal accessor, object.accessor
      assert_equal attributes, object.attributes
    end
  end

  describe '#headers' do
    it 'sets the accept and content-type headers' do
      object = klass.new(client, attributes)
      headers = object.send(:headers)

      expected = 'application/vnd.deere.axiom.v3+json'

      assert_kind_of Hash, headers
      assert_equal expected, headers['Accept']
      assert_equal expected, headers['Content-Type']
    end
  end
end