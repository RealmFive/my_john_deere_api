class MyJohnDeereApi::Consumer
  # user-configurable class attributes
  CONFIG_ATTRIBUTES = [:api_key, :api_secret, :environment, :base_url]

  # valid API urls
  URLS = {
    sandbox: 'https://sandboxapi.deere.com',
    production: 'https://api.soa-proxy.deere.com',
  }

  class << self
    ##
    # get the application's API key
    def api_key
      @api_key ||= nil
    end

    ##
    # set the application's API key
    def api_key=(value)
      @api_key = value
    end

    ##
    # get the application's API secret
    def api_secret
      @api_secret ||= nil
    end

    ##
    # set the application's API secret
    def api_secret=(value)
      @api_secret = value
    end

    ##
    # get the application's API secret
    def environment
      @environment ||= :production
    end

    ##
    # set the application's API secret
    def environment=(value)
      @environment = value
      @base_url = URLS[@environment]
    end

    ##
    # get the application's API secret
    def base_url
      @base_url ||= URLS[environment]
    end

    ##
    # set the application's API secret
    def base_url=(value)
      @base_url = value
    end

    def config
      config_hash = {}

      CONFIG_ATTRIBUTES.each do |attribute|
        config_hash[attribute] = send(attribute)
      end

      config_hash
    end

    def config=(options)
      # Order matters here. Environment must be set before base_url,
      # because environment changes base_url, and then we want a specified
      # base_url to override this if the user took the effort to pass one in.
      #
      # We're also using the defined setters instead of setting the class
      # instance variables directly, to allow for more complex behavior
      # (like environment vs base_url).
      CONFIG_ATTRIBUTES.each do |attribute|
        self.send(:"#{attribute}=", options[attribute]) if options.has_key?(attribute)
      end
    end

    ##
    # oAuth Consumer which uses just the base url, for
    # app-wide, non user-specific GET requests.

    def app_get
      @app_get ||= consumer(base_url)
    end

    ##
    # oAuth Consumer which uses the proper url for user-specific GET requests.

    def user_get
      @user_get ||= consumer("#{base_url}/platform")
    end

    private

    def reset
      remove_instance_variable :@api_key if defined?(@api_key)
      remove_instance_variable :@api_secret if defined?(@api_secret)
      remove_instance_variable :@app_get if defined?(@app_get)
      remove_instance_variable :@user_get if defined?(@user_get)

      self.environment = :production
    end

    def consumer(site)
      OAuth::Consumer.new(
        api_key,
        api_secret,
        site: site,
        header: header,
        http_method: :get,
        request_token_url: links[:request_token],
        access_token_url: links[:access_token],
        authorize_url: links[:authorize_request_token]
      )
    end

    def links
      return @links if defined?(@links)

      catalog = OAuth::Consumer.new(api_key, api_secret)
        .request(
          :get,
          "#{base_url}/platform/",
          nil,
          {},
          header
        ).body

        @links = {}

        JSON.parse(catalog)['links'].each do |link|
          uri = URI.parse(link['uri'])
          uri.query = nil

          @links[keyify(link['rel'])] = uri.to_s
        end

        @links
    end

    def header
      @header ||= {accept: 'application/vnd.deere.axiom.v3+json'}
    end

    def keyify key_name
      key_name.gsub(/^oauth/, '').gsub(/([a-z])([A-Z])/, '\1_\2').downcase.to_sym
    end
  end
end
