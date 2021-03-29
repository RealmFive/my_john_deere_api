module MyJohnDeereApi
  class Client
    include Helpers::EnvironmentHelper
    include Helpers::CaseConversion

    attr_accessor :contribution_definition_id
    attr_reader :api_key, :api_secret, :token_hash, :http_retry_options

    DEFAULTS = {
      environment: :live,
      http_retry: {}
    }

    ##
    # Creates the client with everything it needs to perform API requests.
    # User-specific token_hash is optional, but user-specific API
    # requests are only possible if it is supplied.
    #
    # options:
    #
    # [:environment] :sandbox or :live
    #
    # [:contribution_definition_id] optional, but needed for some requests
    #                               like asset create/update
    #
    # [:token_hash] a hash used to re-create the access token

    def initialize(api_key, api_secret, options = {})
      options = DEFAULTS.merge(options)

      @api_key = api_key
      @api_secret = api_secret

      if options.has_key?(:token_hash) && options[:token_hash].is_a?(Hash)
        @token_hash = options[:token_hash]
      end

      self.environment = options[:environment]
      @contribution_definition_id = options[:contribution_definition_id]
      @http_retry_options = options[:http_retry]
    end

    ##
    # Returns an oAuth AccessToken object which can be used to make
    # user-specific API requests

    def accessor
      return @accessor if defined?(@accessor)

      @accessor = NetHttpRetry::Decorator.new(
        OAuth2::AccessToken.from_hash(oauth_client, token_hash),
        http_retry_options
      )
    end

    ##
    # Returns the URI for the Contribution Definiton ID, if provided

    def contribution_definition_uri
      return @contribution_definition_uri if defined?(@contribution_definition_uri)

      @contribution_definition_uri =
        if contribution_definition_id
          "#{site}/contributionDefinitions/#{contribution_definition_id}"
        else
          nil
        end
    end

    ##
    # Returns the base url for requests

    def site
      return @site if defined?(@site)
      @site = accessor.client.site
    end

    ##
    # generic user-specific GET request method that returns JSON

    def get resource
      response = accessor.get(resource, headers: headers)

      JSON.parse(response.body)
    end

    ##
    # generic user-specific POST request method that returns JSON or response

    def post resource, body
      response = accessor.post(resource, body: camelize(body).to_json, headers: post_headers)

      if response.body && response.body.size > 0
        JSON.parse(response.body)
      else
        response
      end
    end

    ##
    # generic user-specific PUT request method that returns JSON or response

    def put resource, body
      response = accessor.put(resource, body: camelize(body).to_json, headers: post_headers)

      if response.body && response.body.size > 0
        JSON.parse(response.body)
      else
        response
      end
    end

    ##
    # generic user-specific DELETE request method that returns JSON or response

    def delete resource
      response = accessor.delete(resource, headers: headers)

      if response.body && response.body.size > 0
        JSON.parse(response.body)
      else
        response
      end
    end

    ##
    # organizations associated with this access

    def organizations
      return @organizations if defined?(@organizations)
      @organizations = MyJohnDeereApi::Request::Collection::Organizations.new(self)
    end

    ##
    # contribution products associated with this app (not user-specific)

    def contribution_products
      return @contribution_products if defined?(@contribution_products)
      @contribution_products = MyJohnDeereApi::Request::Collection::ContributionProducts.new(self)
    end

    private

    ##
    # Returns an oAuth client which can be used to build requests

    def oauth_client
      return @oauth_client if defined?(@oauth_client)
      @oauth_client = MyJohnDeereApi::Consumer.new(@api_key, @api_secret, environment: environment).platform_client
    end

    def headers
      @headers ||= {accept: 'application/vnd.deere.axiom.v3+json'}
    end

    def post_headers
      @post_headers ||= headers.merge({'Content-Type' => 'application/vnd.deere.axiom.v3+json'})
    end
  end
end