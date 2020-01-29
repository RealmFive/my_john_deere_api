module MyJohnDeereApi
  class Consumer
    include Helpers::CaseConversion

    attr_reader :api_key, :api_secret, :environment, :base_url

    # valid API urls
    URLS = {
      sandbox: 'https://sandboxapi.deere.com',
      live: 'https://api.soa-proxy.deere.com',
    }

    DEFAULTS = {
      environment: :live
    }

    def initialize(api_key, api_secret, options={})
      options = DEFAULTS.merge(options)

      @api_key = api_key
      @api_secret = api_secret

      @environment = options[:environment].to_sym
      @base_url = options[:base_url] || URLS[@environment]
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
      underscore(key_name.gsub(/^oauth/, '')).to_sym
    end
  end
end