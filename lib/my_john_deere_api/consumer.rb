module MyJohnDeereApi
  class Consumer
    include Helpers::CaseConversion
    include Helpers::EnvironmentHelper

    attr_reader :api_key, :api_secret, :environment, :site

    # valid API urls
    URLS = {
      sandbox: 'https://sandboxapi.deere.com',
      live: 'https://partnerapi.deere.com',
    }

    DEFAULTS = {
      environment: :live
    }

    def initialize(api_key, api_secret, options={})
      options = DEFAULTS.merge(options)

      @api_key = api_key
      @api_secret = api_secret

      self.environment = options[:environment]
      @site = options[:site] || URLS[@environment]
    end

    ##
    # oAuth client for platform requests

    def platform_client
      return @platform_client if defined?(@platform_client)

      @platform_client = OAuth2::Client.new(
        api_key,
        api_secret,
        site: site,
        headers: headers,
      )
    end

    ##
    # oAuth client for user authentication

    def auth_client
      return @auth_client if defined?(@auth_client)

      # We build this without the `client` method because the authorization links
      # require an extra API call to JD that is only needed for authorization.

      @auth_client = OAuth2::Client.new(
        api_key,
        api_secret,
        site: site,
        authorize_url: authorization_links[:authorization],
        token_url: authorization_links[:token],
      )
    end

    private

    def authorization
      return @authorization if defined?(@authorization)

      json = OAuth2::Client.new(api_key, api_secret)
        .request(
          :get,
          'https://signin.johndeere.com/oauth2/aus78tnlaysMraFhC1t7/.well-known/oauth-authorization-server',
          headers: headers
        ).body

      @authorization = JSON.parse(json)
    end

    def authorization_links
      return @authorization_links if defined?(@authorization_links)

      @authorization_links = {
        authorization: authorization['authorization_endpoint'],
        token: authorization['token_endpoint'],
        organizations: "https://connections.deere.com/connections/#{api_key}/select-organizations",
      }
    end

    def scopes
      return @scopes if defined?(@scopes)
      @scopes = authorization['scopes_supported']
    end

    def headers
      @headers ||= {accept: 'application/vnd.deere.axiom.v3+json'}
    end

    def keyify key_name
      underscore(key_name.gsub(/^oauth/, '')).to_sym
    end
  end
end