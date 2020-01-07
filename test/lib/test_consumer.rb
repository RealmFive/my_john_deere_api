require 'support/helper'

describe JD::Consumer do
  before do
    JD::Consumer.send(:reset)
  end

  describe 'api_key' do
    it 'can be set' do
      JD::Consumer.api_key = 'key'
      assert JD::Consumer
    end

    it 'can be retrieved' do
      JD::Consumer.api_key = 'key'
      assert_equal 'key', JD::Consumer.api_key
    end
  end

  describe 'api_secret' do
    it 'can be set' do
      JD::Consumer.api_secret = 'secret'
      assert JD::Consumer
    end

    it 'can be retrieved' do
      JD::Consumer.api_secret = 'secret'
      assert_equal 'secret', JD::Consumer.api_secret
    end
  end

  describe 'base_url' do
    it 'can be set' do
      JD::Consumer.base_url = 'http://example.com'
      assert JD::Consumer
    end

    it 'can be retrieved' do
      JD::Consumer.base_url = 'http://example.com'
      assert_equal 'http://example.com', JD::Consumer.base_url
    end
  end

  describe 'environment' do
    it 'can be set' do
      JD::Consumer.environment = :sandbox
      assert JD::Consumer
    end

    it 'can be retrieved' do
      JD::Consumer.environment = :sandbox
      assert_equal :sandbox, JD::Consumer.environment
    end

    it 'defaults to :production' do
      assert_equal :production, JD::Consumer.environment
    end

    it 'sets the sandbox url' do
      JD::Consumer.environment = :sandbox
      assert_equal 'https://sandboxapi.deere.com', JD::Consumer.base_url
    end

    it 'sets the production url' do
      JD::Consumer.environment = :production
      assert_equal 'https://api.soa-proxy.deere.com', JD::Consumer.base_url
    end

    it 'defaults to the production url' do
      assert_equal 'https://api.soa-proxy.deere.com', JD::Consumer.base_url
    end
  end

  describe 'config' do
    it 'sets all config variables at once' do
      key = 'key'
      secret = 'secret'
      environment = 'cozy'
      base_url = 'http://example.com/cozy'

      JD::Consumer.config = {
        api_key: key,
        api_secret: secret,
        environment: environment,
        base_url: base_url
      }

      assert_equal key, JD::Consumer.api_key
      assert_equal secret, JD::Consumer.api_secret
      assert_equal environment, JD::Consumer.environment
      assert_equal base_url, JD::Consumer.base_url
    end

    it 'gets all config variables at once' do
      key = 'key'
      secret = 'secret'
      environment = 'cozy'
      base_url = 'http://example.com/cozy'

      JD::Consumer.config = {
        api_key: key,
        api_secret: secret,
        environment: environment,
        base_url: base_url
      }

      config = JD::Consumer.config

      assert_kind_of Hash, config
      assert_equal key, config[:api_key]
      assert_equal secret, config[:api_secret]
      assert_equal environment, config[:environment]
      assert_equal base_url, config[:base_url]
    end
  end

  describe 'app_get' do
    it 'creates a working oAuth consumer for non-user-specific GET requests' do
      JD::Consumer.config = {
        api_key: API_KEY,
        api_secret: API_SECRET,
        environment: :sandbox
      }

      JD::Consumer.environment = :sandbox
      app_get = VCR.use_cassette('app_consumer') { JD::Consumer.app_get }

      assert_kind_of OAuth::Consumer, app_get
      assert_equal API_KEY, app_get.key
      assert_equal API_SECRET, app_get.secret
      assert_equal JD::Consumer::URLS[:sandbox], app_get.site
    end
  end

  describe 'user_get' do
    it 'creates a working oAuth consumer for user-specific GET requests' do
      JD::Consumer.config = {
        api_key: API_KEY,
        api_secret: API_SECRET,
        environment: :sandbox
      }

      JD::Consumer.environment = :sandbox
      user_get = VCR.use_cassette('app_consumer') { JD::Consumer.user_get }

      assert_kind_of OAuth::Consumer, user_get
      assert_equal API_KEY, user_get.key
      assert_equal API_SECRET, user_get.secret
      assert_equal "#{JD::Consumer::URLS[:sandbox]}/platform", user_get.site
    end
  end
end