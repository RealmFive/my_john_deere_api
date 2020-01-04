require 'support/helper'

class AuthorizeTest < MiniTest::Test
  describe 'initialization' do
    it "accepts an API key and secret" do
      authorize = JD::Authorize.new('key', 'secret')

      assert_equal 'key', authorize.api_key
      assert_equal 'secret', authorize.api_secret
    end
  end
end