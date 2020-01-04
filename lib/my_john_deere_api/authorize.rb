class MyJohnDeereApi::Authorize
  attr_reader :api_key, :api_secret, :request_token, :request_secret
  attr_accessor :base_url

  DEFAULTS = {
    base_url: 'https://api.soa-proxy.deere.com',
  }

  def initialize(api_key, api_secret, options={})
    @api_key = api_key
    @api_secret = api_secret
    @base_url = options[:base_url] || ENV['MY_JOHN_DEERE_URL'] || DEFAULTS[:base_url]
  end

  def authorize_url
    # return @authorize_url if defined?(@authorize_url)
    #

    consumer = OAuth::Consumer.new(
      api_key,
      api_secret,
      site: base_url,
      header: header,
      http_method: :get,
      request_token_url: links[:request_token],
      access_token_url: links[:access_token],
      authorize_url: links[:authorize_request_token]
    )

    requester = consumer.get_request_token

    @request_token = requester.token
    @request_secret = requester.secret

    @authorize_url = requester.authorize_url
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

  private

  def header
    {accept: 'application/vnd.deere.axiom.v3+json'}
  end

  def keyify key_name
    key_name.gsub(/^oauth/, '').gsub(/([a-z])([A-Z])/, '\1_\2').downcase.to_sym
  end
end