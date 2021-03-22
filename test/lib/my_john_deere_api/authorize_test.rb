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
    it 'sets the access/refresh token hash' do
      authorize = create_authorize
      code = 'VERIFY'

      VCR.use_cassette('get_request_url') { authorize.authorize_url }
      VCR.use_cassette('get_access_token') { authorize.verify(code) }

      hash = authorize.token_hash

      assert_match TOKEN_PATTERN, hash['access_token']
      assert_match TOKEN_PATTERN, hash['refresh_token']
    end
  end

  describe '#refresh_from_hash(old_token_hash)' do
    let(:authorize) { create_authorize }

    let(:old_hash) do
      {
        "token_type": "Bearer",
        "scope": "ag2 ag1 offline_access ag3",
        "access_token": access_token,
        "refresh_token": refresh_token,
        "expires_at": 1616484631
      }
    end

    subject { authorize.refresh_from_hash(old_hash) }

    it "fetches a new token hash using OAuth2's refresh! method" do
      new_hash = VCR.use_cassette('get_refresh_token') { subject }

      # normalize response hash
      new_hash = JSON.parse(new_hash.to_json)

      assert_equal new_access_token, new_hash['access_token']
    end
  end
end