class MyJohnDeereApi::Authorize
  attr_reader :api_key, :api_secret

  def initialize api_key, api_secret
    @api_key = api_key
    @api_secret = api_secret
  end

  def links
    return @links if defined?(@links)

    catalog = OAuth::Consumer.new(api_key, api_secret)
      .request(
        :get,
        'https://sandboxapi.deere.com/platform/',
        nil,
        {},
        header
      ).body

      @links = {}

      JSON.parse(catalog)['links'].each do |link|
        @links[keyify(link['rel'])] = link['uri']
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