class MyJohnDeereApi::Authorize
  attr_reader :api_key, :api_secret

  def initialize api_key, api_secret
    @api_key = api_key
    @api_secret = api_secret
  end
end