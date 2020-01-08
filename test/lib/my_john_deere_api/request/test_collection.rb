require 'support/helper'

describe 'MyJohnDeereApi::Request::Collection' do
  let(:client) { JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET]) }
  let(:accessor) { VCR.use_cassette('catalog') { client.send(:accessor) } }

  describe '#initialize(access_token)' do
    it 'accepts an access token' do
      collection = JD::Request::Collection.new(accessor)
      assert_kind_of OAuth::AccessToken, collection.accessor
    end
  end

  it 'uses the Enumerable module' do
    collection = JD::Request::Collection.new(accessor)

    [:each, :first, :map, :detect, :select].each do |method_name|
      assert collection.respond_to?(method_name)
    end
  end
end