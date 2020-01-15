module MyJohnDeereApi
  ##
  # This error is used in a context that will fail in the absence of
  # a valid oAuth access token. We have classes that may only need 
  # access tokens for some use cases.

  class TypeMismatchError < StandardError
    def initialize(message = "Record type does not match what was expected")
      super
    end
  end
end