module MyJohnDeereApi
  class Authorize
    include Helpers::EnvironmentHelper

    attr_reader :api_key, :api_secret, :environment, :options, :token_hash

    DEFAULTS = {
      environment: :live
    }

    ##
    # Create an Authorize object.
    #
    # This is used to obtain authentication an access key/secret
    # on behalf of a user.
    #
    # parameters:
    #
    #     api_key - required JD API key for client application
    #     api_secret - required JD API secret for client application
    #     options - options hash, see below for details
    #
    # options:
    #
    #     :environment - one of [:live, :staging]
    #     :scope - a space-delimited list of scopes requested
    #     :scopes - an array of scopes requested. 'offline_access' will be added if
    #               it isn't included already. This will overwrite :scope option if
    #               both are provided.
    #     :state -  a unique identifier for this request. JD will return this when
    #               it redirects back after authorization, so that the client can identify
    #               which of its users this request belongs to.
    #     :redirect_uri - the uri for JD to redirect back to, after authorization.


    def initialize(api_key, api_secret, options = {})
      @options = DEFAULTS.merge(options)

      @api_key = api_key
      @api_secret = api_secret
      self.environment = @options[:environment]

      # This is only set upon verification
      @token_hash = nil
    end

    ##
    # Url which may be used to obtain a verification
    # code from the oauth server.

    def authorize_url
      return @authorize_url if defined?(@authorize_url)

      request_options = options.slice(:redirect_uri, :state, :scope)

      if options.key?(:scopes)
        options[:scopes] << 'offline_access' unless options[:scopes].include?('offline_access')
        request_options[:scope] = options[:scopes].join(' ')
      end

      # generate a default unique-ish "state" key if not provided
      unless request_options.key?(:state)
        request_options[:state] = (rand(8000) + 1000).to_s
      end

      @authorize_url = oauth_client.auth_code.authorize_url(request_options)
    end

    ##
    # API client that makes authentication requests

    def oauth_client
      return @oauth_client if defined?(@oauth_client)
      @oauth_client = MyJohnDeereApi::Consumer.new(@api_key, @api_secret, environment: environment).auth_client
    end

    ##
    # Turn a verification code into access token.

    def verify(code)
      token = oauth_client.auth_code.get_token(code, redirect_uri: options[:redirect_uri])

      # normalize hash
      @token_hash = token.to_hash.transform_keys(&:to_s)
    end

    ##
    # Use an old token hash to generate a new token hash.

    def refresh_from_hash(old_token_hash)
      old_token = OAuth2::AccessToken.from_hash(oauth_client, old_token_hash)
      new_token = old_token.refresh!

      new_token.to_hash
    end
  end
end