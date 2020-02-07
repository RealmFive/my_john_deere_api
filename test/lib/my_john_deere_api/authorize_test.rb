require 'uri'
require 'cgi'
require 'support/helper'

def contains_parameters?(uri)
  !URI.parse(uri).query.nil?
end

def create_authorize
  VCR.use_cassette('catalog'){ JD::Authorize.new(api_key, api_secret, environment: :sandbox) }
end

def fancy_url
  'https://example.com/turtles'
end

describe 'MyJohnDeereApi::Authorize' do
  describe 'initialization' do
    it 'sets the api key/secret' do
      authorize = VCR.use_cassette('catalog') { JD::Authorize.new(api_key, api_secret) }

      assert_equal api_key, authorize.api_key
      assert_equal api_secret, authorize.api_secret
    end

    it 'accepts the environment' do
      environment = :sandbox

      authorize = VCR.use_cassette('catalog') { JD::Authorize.new(api_key, api_secret, environment: environment) }
      assert_equal environment, authorize.environment
    end
  end

  describe '#consumer' do
    it "returns a non-user-specific consumer configured for GET requests" do
      authorize = create_authorize
      consumer = VCR.use_cassette('catalog') { authorize.consumer }

      assert_kind_of OAuth::Consumer, consumer
      assert_equal :get, consumer.http_method
    end
  end

  describe '#authorize_url' do
    it 'retrieves a request url' do
      authorize = create_authorize

      url = VCR.use_cassette('get_request_token') { authorize.authorize_url }
      links = VCR.use_cassette('catalog') { JD::Consumer.new(api_key, api_secret, environment: :sandbox).send(:links) }

      assert_includes url, links[:authorize_request_token]

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
end