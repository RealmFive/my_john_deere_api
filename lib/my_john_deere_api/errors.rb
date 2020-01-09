module MyJohnDeereApi
  class AccessTokenError < StandardError
    def initialize(message = "A valid oAuth Access Token must be supplied to use this feature.")
      super
    end
  end
end