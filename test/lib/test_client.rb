require 'support/helper'

describe 'MyJohnDeereApi::Client' do
  describe '#initialize(api_key, api_secret)' do
    it 'sets the api key/secret' do
      client = JD::Client.new(API_KEY, API_SECRET)

      assert_equal API_KEY, client.api_key
      assert_equal API_SECRET, client.api_secret
    end

    it 'accepts access token/secret' do
      access_token = 'token'
      access_secret = 'secret'

      client = JD::Client.new(API_KEY, API_SECRET, access: [access_token, access_secret])

      assert_equal access_token, client.access_token
      assert_equal access_secret, client.access_secret
    end

    it 'accepts environment' do
      environment = :sandbox

      client = JD::Client.new(API_KEY, API_SECRET, environment: environment)
      assert_equal environment, client.environment
    end

    it 'defaults the environment to production' do
      environment = :production

      client = JD::Client.new(API_KEY, API_SECRET)
      assert_equal environment, client.environment
    end
  end

  describe '#consumer' do
    it 'receives the api key/secret and environment of the client' do
      environment = :sandbox

      client = JD::Client.new(API_KEY, API_SECRET, environment: environment)
      consumer = client.send :consumer

      assert_kind_of JD::Consumer, consumer
      assert_equal API_KEY, consumer.api_key
      assert_equal API_SECRET, consumer.api_secret
      assert_equal environment, consumer.environment
    end
  end

  describe '#accessor' do
    it 'returns an object that can make user-specific requests' do
      client = JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET])
      consumer = client.send(:consumer)
      accessor = VCR.use_cassette('catalog') { client.send :accessor }

      assert_kind_of OAuth::AccessToken, accessor
      assert_kind_of OAuth::Consumer, accessor.consumer
      assert_equal ACCESS_TOKEN, accessor.token
      assert_equal ACCESS_SECRET, accessor.secret
    end
  end
end