require 'support/helper'

class ClientTest < MiniTest::Test
  describe '#initialize(api_key, api_secret, user_key=nil, user_secret=nil)' do
    it 'sets the passed-in variables' do
      client = JD::Client.new('api_key', 'api_secret', 'access_token', 'access_secret')

      assert_equal 'api_key', client.api_key
      assert_equal 'api_secret', client.api_secret
      assert_equal 'access_token', client.access_token
      assert_equal 'access_secret', client.access_secret
    end

    it 'does not require access token/secret' do
      client = JD::Client.new('api_key', 'api_secret')

      assert_equal 'api_key', client.api_key
      assert_equal 'api_secret', client.api_secret
      assert_nil client.access_token
      assert_nil client.access_secret
    end
  end
end