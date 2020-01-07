class MyJohnDeereApi::Client
  attr_reader :api_key, :api_secret, :access_token, :access_secret, :consumer

  def initialize(api_key, api_secret, access_token = nil, access_secret = nil)
    @api_key = api_key
    @api_secret = api_secret

    @access_token = access_token if access_token
    @access_secret = access_secret if access_secret

    # @consumer =
  end
end