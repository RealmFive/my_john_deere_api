module MyJohnDeereApi
  class Authorize
    include Helpers::EnvironmentHelper

    attr_reader :api_key, :api_secret,
      :request_token, :request_secret,
      :access_token, :access_secret,
      :environment, :options

    DEFAULTS = {
      environment: :live
    }

    ##
    # Create an Authorize object.
    #
    # This is used to obtain authentication an access key/secret
    # on behalf of a user.

    def initialize(api_key, api_secret, options = {})
      @options = DEFAULTS.merge(options)

      @api_key = api_key
      @api_secret = api_secret
      self.environment = @options[:environment]
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
      oauth_client.auth_code.get_token(code)
    end

    ##
    # Use an old token hash to generate a new token hash.

    def refresh_from_hash(token_hash)
      old_token = OAuth2::AccessToken.from_hash(oauth_client, token_hash)
      new_token = old_token.refresh!

      new_token.to_hash
    end
  end
end