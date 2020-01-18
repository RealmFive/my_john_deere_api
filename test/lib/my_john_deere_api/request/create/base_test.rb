require 'support/helper'

describe 'MyJohnDeereApi::Request::Create::Base' do
  let(:client) { JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET]) }
  let(:accessor) { VCR.use_cassette('catalog') { client.send(:accessor) } }
  let(:attributes) { {} }

  describe '#initialize(access_token, attributes)' do
    it 'accepts an accessor and attributes' do
      object = JD::Request::Create::AssetLocation.new(accessor, attributes)

      assert_equal accessor, object.accessor
      assert_equal attributes, object.attributes
    end

    it 'creates an empty error hash' do
      object = JD::Request::Create::AssetLocation.new(accessor, {})
      assert_equal({}, object.errors)
    end
  end

  describe '#headers' do
    it 'sets the accept and content-type headers' do
      object = JD::Request::Create::Asset.new(accessor, attributes)
      headers = object.send(:headers)

      expected = 'application/vnd.deere.axiom.v3+json'

      assert_kind_of Hash, headers
      assert_equal expected, headers['Accept']
      assert_equal expected, headers['Content-Type']
    end
  end
end