module MyJohnDeereApi
  ##
  # This error is used in a context that will fail in the absence of
  # a valid oAuth access token. We have classes that may only need 
  # access tokens for some use cases.

  class MissingContributionDefinitionIdError < StandardError
    def initialize(message = "Contribution Definition ID must be set in the client to use this feature.")
      super
    end
  end
end