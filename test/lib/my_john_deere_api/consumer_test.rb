require 'support/helper'

describe 'JD::Consumer' do
  describe '#initialize' do
    it 'requires an api key and secret' do
      consumer = JD::Consumer.new(api_key, api_secret)

      assert_equal api_key, consumer.api_key
      assert_equal api_secret, consumer.api_secret
    end

    it 'accepts the environment' do
      environment = :sandbox
      consumer = JD::Consumer.new(api_key, api_secret, environment: environment)

      assert_equal environment, consumer.environment
      assert_equal JD::Consumer::URLS[environment], consumer.site
    end

    it 'accepts an arbitrary site' do
      site = 'https://example.com'
      consumer = JD::Consumer.new(api_key, api_secret, site: site)

      assert_equal site, consumer.site
    end

    it 'uses specified site regardless of specified environment' do
      site = 'https://example.com'
      consumer = JD::Consumer.new(api_key, api_secret, site: site, environment: :sandbox)

      assert_equal site, consumer.site
    end
  end

  describe '#platform_client' do
    it 'creates a working oAuth client' do
      consumer = JD::Consumer.new(api_key, api_secret, environment: :sandbox)
      platform_client = VCR.use_cassette('catalog') { consumer.platform_client }

      assert_kind_of OAuth2::Client, platform_client
      assert_equal api_key, platform_client.id
      assert_equal api_secret, platform_client.secret
      assert_equal JD::Consumer::URLS[:sandbox], platform_client.site
    end
  end
end