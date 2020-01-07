require 'uri'
require 'cgi'
require 'support/helper'

def contains_parameters?(uri)
  !URI.parse(uri).query.nil?
end

def create_authorize
  JD::Authorize.new(API_KEY, API_SECRET, environment: :sandbox)
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

    it 'defaults to production environment' do
      authorize = JD::Authorize.new('key', 'secret')
      assert_equal :production, authorize.environment
    end

    it 'defaults to production oauth url' do
      authorize = JD::Authorize.new('key', 'secret')
      assert_equal 'https://api.soa-proxy.deere.com', authorize.base_url
    end

    it "can set the environment" do
      authorize = JD::Authorize.new('key', 'secret', environment: :sandbox)
      assert_equal :sandbox, authorize.environment
    end

    it "can set the base_url via the environment" do
      authorize = JD::Authorize.new('key', 'secret', environment: :sandbox)
      assert_equal 'https://sandboxapi.deere.com', authorize.base_url
    end
  end

  describe '#authorize_url' do
    it 'retrieves a request url' do
      authorize = create_authorize

      url = VCR.use_cassette('get_request_token') { authorize.authorize_url }

      assert_includes url, "#{authorize.send(:links)[:authorize_request_token]}?oauth_token="

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

  describe '#verify(code, token, secret)' do
    it 'sets the access token/secret' do
      authorize = create_authorize
      code = 'VERIFY'

      VCR.use_cassette('get_request_token') { authorize.authorize_url }
      VCR.use_cassette('get_access_token') { authorize.verify(code) }

      assert_match TOKEN_PATTERN, authorize.access_token
      assert_match SECRET_PATTERN, authorize.access_secret
    end
  end

  describe '#links' do
    it "returns a list of catalog urls" do
      authorize = create_authorize

      links = VCR.use_cassette("catalog"){ authorize.send(:links) }

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