require 'support/helper'

describe 'MyJohnDeereApi::Request::Create::Asset' do
  let(:client) { JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET]) }
  let(:accessor) { VCR.use_cassette('catalog') { client.send(:accessor) } }

  describe '#initialize(access_token, attributes)' do

  end
end