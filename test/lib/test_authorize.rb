require 'uri'
require 'cgi'
require 'support/helper'

URL_ENV = 'MY_JOHN_DEERE_URL'
TOKEN_PATTERN = /^[0-9a-z\-]+$/
SECRET_PATTERN = /^[0-9A-Za-z\-+=\/]+$/
API_KEY = ENV['API_KEY']
API_SECRET = ENV['API_SECRET']

def contains_parameters?(uri)
  !URI.parse(uri).query.nil?
end

def create_authorize
  JD::Authorize.new(API_KEY, API_SECRET, base_url: 'https://sandboxapi.deere.com')
end

def fancy_url
  'https://example.com/turtles'
end

class AuthorizeTest < MiniTest::Test
  describe 'initialization' do
    it "accepts an API key and secret" do
      authorize = JD::Authorize.new('key', 'secret')

      assert_equal 'key', authorize.api_key
      assert_equal 'secret', authorize.api_secret
    end

    it "can set the base_url" do
      authorize = JD::Authorize.new('key', 'secret', base_url: fancy_url)
      assert_equal fancy_url, authorize.base_url
    end

    it 'prefers passed-in base_url over ENV variable' do
      ENV[URL_ENV] = 'https://example.com/disposable'

      authorize = JD::Authorize.new('key', 'secret', base_url: fancy_url)
      assert_equal fancy_url, authorize.base_url

      ENV.delete(URL_ENV)
    end
  end

  describe '#authorize_url' do
    it 'retrieves a request url' do
      authorize = create_authorize

      url = VCR.use_cassette('get_request_token') { authorize.authorize_url }

      assert_includes url, "#{authorize.links[:authorize_request_token]}?oauth_token="

      query = URI.parse(url).query
      params = CGI::parse(query)

      assert_match(TOKEN_PATTERN, params['oauth_token'].first)
    end

    it 'sets the request token/secret' do
      authorize = create_authorize

      VCR.use_cassette('get_request_token') { authorize.authorize_url }

      assert_match TOKEN_PATTERN, authorize.request_token
      assert_match SECRET_PATTERN, authorize.request_secret
    end
  end

  describe '#links' do
    it "returns a list of catalog urls" do
      authorize = create_authorize

      links = VCR.use_cassette("catalog"){ authorize.links }

      assert_kind_of Hash, links

      [:request_token, :authorize_request_token, :access_token].each do |link|
        assert links.has_key?(link)
        refute contains_parameters?(links[link])
      end
    end
  end

  describe '#base_url' do
    it 'defaults to production deere url' do
      authorize = JD::Authorize.new('key', 'secret')
      assert_equal 'https://api.soa-proxy.deere.com', authorize.base_url
    end

    it 'can be set via accessor' do
      authorize = create_authorize
      authorize.base_url = fancy_url

      assert_equal fancy_url, authorize.base_url
    end

    it 'can be set via environment variable' do
      ENV[URL_ENV] = fancy_url

      authorize = JD::Authorize.new('key', 'secret')
      assert_equal fancy_url, authorize.base_url

      ENV.delete(URL_ENV)
    end
  end

  describe '#app_consumer' do
    it 'creates a working oAuth consumer for non-user-specific requests' do
      auth = create_authorize
      app_consumer = VCR.use_cassette('app_consumer') { auth.app_consumer }

      assert_kind_of OAuth::Consumer, app_consumer
      assert_equal API_KEY, app_consumer.key
      assert_equal API_SECRET, app_consumer.secret
      assert_equal auth.base_url, app_consumer.site
    end
  end

  describe '#user_consumer' do
    it 'creates a working oAuth consumer for user-specific requests' do
      auth = create_authorize
      user_consumer = VCR.use_cassette('app_consumer') { auth.user_consumer }

      assert_kind_of OAuth::Consumer, user_consumer
      assert_equal API_KEY, user_consumer.key
      assert_equal API_SECRET, user_consumer.secret
      assert_equal "#{auth.base_url}/platform", user_consumer.site
    end
  end
end