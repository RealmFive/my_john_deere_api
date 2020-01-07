require 'uri'
require 'cgi'
require 'support/helper'

def contains_parameters?(uri)
  !URI.parse(uri).query.nil?
end

def create_authorize
  VCR.use_cassette('catalog'){ JD::Consumer.send(:links) }
  JD::Authorize.new
end

def fancy_url
  'https://example.com/turtles'
end

describe 'MyJohnDeereApi::Authorize' do
  before do
    JD::Consumer.config = {
      api_key: API_KEY,
      api_secret: API_SECRET,
      environment: :sandbox
    }
  end

  describe 'initialization' do
    it "sets the consumer to an app consumer with get requests" do
      authorize = create_authorize

      assert_kind_of OAuth::Consumer, authorize.consumer
      assert_equal :get, authorize.consumer.http_method
    end
  end

  describe '#authorize_url' do
    it 'retrieves a request url' do
      authorize = create_authorize

      url = VCR.use_cassette('get_request_token') { authorize.authorize_url }
      links = VCR.use_cassette('catalog') { JD::Consumer.send(:links) }

      assert_includes url, "#{links[:authorize_request_token]}?oauth_token="

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