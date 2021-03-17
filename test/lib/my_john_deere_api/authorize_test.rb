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

  describe '#oauth_client' do
    it "returns a non-user-specific client" do
      authorize = create_authorize
      consumer = VCR.use_cassette('catalog') { authorize.oauth_client }

      assert_kind_of OAuth2::Client, consumer
    end
  end

  describe '#authorize_url' do
    it 'retrieves a request url' do
      authorize = create_authorize

      url = VCR.use_cassette('get_request_url') { authorize.authorize_url }
      links = VCR.use_cassette('catalog') { JD::Consumer.new(api_key, api_secret, environment: :sandbox).send(:authorization_links) }

      assert_includes url, links[:authorization]
    end
  end

  describe '#verify(code)' do
    it 'sets the access/refresh token' do
      authorize = create_authorize
      code = 'VERIFY'

      VCR.use_cassette('get_request_url') { authorize.authorize_url }
      token = VCR.use_cassette('get_access_token') { authorize.verify(code) }

      # normalize hash
      token = JSON.parse(token.to_hash.to_json)

      assert_match TOKEN_PATTERN, token['access_token']
      assert_match TOKEN_PATTERN, token['refresh_token']
    end
  end
end