class MyJohnDeereApi::Authorize
  attr_reader :api_key, :api_secret, :request_token, :request_secret, :access_token, :access_secret, :environment
  attr_accessor :base_url

  URLS = {
    sandbox: 'https://sandboxapi.deere.com',
    production: 'https://api.soa-proxy.deere.com',
  }

  DEFAULTS = {
    environment: :production,
  }



  def initialize(api_key, api_secret, options={})
    options = DEFAULTS.merge(options)

    @api_key = api_key
    @api_secret = api_secret
    @environment = options[:environment]
    @base_url = options[:base_url] || URLS[@environment]
  end

  def authorize_url
    return @authorize_url if defined?(@authorize_url)

    requester = app_consumer.get_request_token
    @request_token = requester.token
    @request_secret = requester.secret

    @authorize_url = requester.authorize_url
  end

  def verify(code, token=nil, secret=nil)
    token ||= request_token
    secret ||= request_secret

    requester = OAuth::RequestToken.new(app_consumer, token, secret)
    access_object = requester.get_access_token(oauth_verifier: code)
    @access_token = access_object.token
    @access_secret = access_object.secret
    nil
  end

  def app_consumer
    @app_consumer ||= consumer(base_url)
  end

  def user_consumer
    @user_consumer ||= consumer("#{base_url}/platform")
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

  private

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
    {accept: 'application/vnd.deere.axiom.v3+json'}
  end

  def keyify key_name
    key_name.gsub(/^oauth/, '').gsub(/([a-z])([A-Z])/, '\1_\2').downcase.to_sym
  end
end