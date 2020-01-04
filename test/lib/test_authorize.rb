require 'support/helper'

class AuthorizeTest < MiniTest::Test
  describe 'initialization' do
    it "accepts an API key and secret" do
      authorize = JD::Authorize.new('key', 'secret')

      assert_equal 'key', authorize.api_key
      assert_equal 'secret', authorize.api_secret
    end
  end

  describe 'links' do
    it "returns a list of catalog urls" do
      authorize = JD::Authorize.new(ENV['API_KEY'], ENV['API_SECRET'])

      links = VCR.use_cassette("catalog"){ authorize.links }

      assert_kind_of Hash, links

      assert links.has_key?(:request_token)
      assert links.has_key?(:authorize_request_token)
      assert links.has_key?(:access_token)
    end
  end
end