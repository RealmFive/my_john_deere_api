module MyJohnDeereApi
  class Consumer
    include Helpers::CaseConversion
    include Helpers::EnvironmentHelper

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

      self.environment = options[:environment]
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
        request_token_url: authorization_links[:request_token],
        access_token_url: authorization_links[:access_token],
        authorize_url: authorization_links[:authorize_request_token]
      )
    end

    def authorization_links
      return @authorization_links if defined?(@authorization_links)

      catalog = OAuth::Consumer.new(api_key, api_secret)
        .request(
          :get,
          "#{base_url}/platform/",
          nil,
          {},
          header
        ).body

        @authorization_links = JSON.parse(catalog)['links'].each_with_object({}) do |link, hash|
          uri = URI.parse(link['uri'])
          uri.query = nil

          hash[keyify(link['rel'])] = uri.to_s
        end
    end

    def header
      @header ||= {accept: 'application/vnd.deere.axiom.v3+json'}
    end

    def keyify key_name
      underscore(key_name.gsub(/^oauth/, '')).to_sym
    end
  end
end