require 'support/helper'

describe 'JD::Consumer' do
  describe '#initialize' do
    it 'requires an api key and secret' do
      consumer = JD::Consumer.new(API_KEY, API_SECRET)

      assert_equal API_KEY, consumer.api_key
      assert_equal API_SECRET, consumer.api_secret
    end

    it 'accepts sandbox environment' do
      environment = :sandbox
      consumer = JD::Consumer.new(API_KEY, API_SECRET, environment: environment)

      assert_equal environment, consumer.environment
      assert_equal JD::Consumer::URLS[environment], consumer.base_url
    end

    it 'accepts live environment' do
      environment = :live
      consumer = JD::Consumer.new(API_KEY, API_SECRET, environment: environment)

      assert_equal environment, consumer.environment
      assert_equal JD::Consumer::URLS[environment], consumer.base_url
    end

    it 'defaults to live environment' do
      default_environment = :live
      consumer = JD::Consumer.new(API_KEY, API_SECRET)

      assert_equal default_environment, consumer.environment
      assert_equal JD::Consumer::URLS[default_environment], consumer.base_url
    end

    it 'converts environment string to symbol' do
      environment = 'sandbox'
      consumer = JD::Consumer.new(API_KEY, API_SECRET, environment: environment)

      assert_equal environment.to_sym, consumer.environment
      assert_equal JD::Consumer::URLS[environment.to_sym], consumer.base_url
    end

    it 'accepts an arbitrary base_url' do
      base_url = 'https://example.com'
      consumer = JD::Consumer.new(API_KEY, API_SECRET, base_url: base_url)

      assert_equal base_url, consumer.base_url
    end

    it 'uses specified base_url regardless of specified environment' do
      base_url = 'https://example.com'
      consumer = JD::Consumer.new(API_KEY, API_SECRET, base_url: base_url, environment: :sandbox)

      assert_equal base_url, consumer.base_url
    end
  end

  describe '#app_get' do
    it 'creates a working oAuth consumer for non-user-specific GET requests' do
      consumer = JD::Consumer.new(API_KEY, API_SECRET, environment: :sandbox)
      app_get = VCR.use_cassette('app_consumer') { consumer.app_get }

      assert_kind_of OAuth::Consumer, app_get
      assert_equal API_KEY, app_get.key
      assert_equal API_SECRET, app_get.secret
      assert_equal JD::Consumer::URLS[:sandbox], app_get.site
    end
  end

  describe '#user_get' do
    it 'creates a working oAuth consumer for user-specific GET requests' do
      consumer = JD::Consumer.new(API_KEY, API_SECRET, environment: :sandbox)
      user_get = VCR.use_cassette('app_consumer') { consumer.user_get }

      assert_kind_of OAuth::Consumer, user_get
      assert_equal API_KEY, user_get.key
      assert_equal API_SECRET, user_get.secret
      assert_equal "#{JD::Consumer::URLS[:sandbox]}/platform", user_get.site
    end
  end
end