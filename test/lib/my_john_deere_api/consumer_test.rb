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
      assert_equal JD::Consumer::URLS[environment], consumer.base_url
    end

    it 'accepts an arbitrary base_url' do
      base_url = 'https://example.com'
      consumer = JD::Consumer.new(api_key, api_secret, base_url: base_url)

      assert_equal base_url, consumer.base_url
    end

    it 'uses specified base_url regardless of specified environment' do
      base_url = 'https://example.com'
      consumer = JD::Consumer.new(api_key, api_secret, base_url: base_url, environment: :sandbox)

      assert_equal base_url, consumer.base_url
    end
  end

  describe '#app_get' do
    it 'creates a working oAuth consumer for non-user-specific GET requests' do
      consumer = JD::Consumer.new(api_key, api_secret, environment: :sandbox)
      app_get = VCR.use_cassette('catalog') { consumer.app_get }

      assert_kind_of OAuth::Consumer, app_get
      assert_equal api_key, app_get.key
      assert_equal api_secret, app_get.secret
      assert_equal JD::Consumer::URLS[:sandbox], app_get.site
    end
  end

  describe '#user_get' do
    it 'creates a working oAuth consumer for user-specific GET requests' do
      consumer = JD::Consumer.new(api_key, api_secret, environment: :sandbox)
      user_get = VCR.use_cassette('catalog') { consumer.user_get }

      assert_kind_of OAuth::Consumer, user_get
      assert_equal api_key, user_get.key
      assert_equal api_secret, user_get.secret
      assert_equal "#{JD::Consumer::URLS[:sandbox]}/platform", user_get.site
    end
  end
end