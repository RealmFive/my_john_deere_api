module MyJohnDeereApi
  ##
  # This error is used in a context that will fail in the absence of
  # a valid oAuth access token. We have classes that may only need 
  # access tokens for some use cases.

  class NotYetImplementedError < StandardError
    def initialize(message = 'This is not yet implemented. View README to help make this gem better!')
      super
    end
  end
end