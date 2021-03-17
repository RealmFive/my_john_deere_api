require 'support/helper'

describe 'MyJohnDeereApi::Request::Create::Base' do
  let(:klass) { JD::Request::Create::Base }
  let(:attributes) { {} }

  describe '#initialize(client, attributes)' do
    it 'accepts a client and attributes' do
      object = klass.new(client, attributes)

      assert_equal client, object.client
      assert_equal attributes, object.attributes
    end
  end
end