module MyJohnDeereApi
  ##
  # This error is used in a context that will fail in the absence of
  # a valid oAuth access token. We have classes that may only need 
  # access tokens for some use cases.

  class AccessTokenError < StandardError
    def initialize(message = "A valid oAuth Access Token must be supplied to use this feature.")
      super
    end
  end
end