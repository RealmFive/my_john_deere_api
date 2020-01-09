class MyJohnDeereApi::Client
  attr_reader :api_key, :api_secret, :access_token, :access_secret, :environment

  DEFAULTS = {
    environment: :production
  }

  ##
  # Creates the client with everthing it needs to perform API requests.
  # User-specific credentials are optional, but user-specific API
  # requests are only possible if they are supplied.
  #
  # options:
  #
  # [:environment] :sandbox or :production
  #
  # [:access] an array with two elements, the access_token
  #           and the access_secret of the given user

  def initialize(api_key, api_secret, options = {})
    options = DEFAULTS.merge(options)

    @api_key = api_key
    @api_secret = api_secret

    if options.has_key?(:access) && options[:access].is_a?(Array)
      @access_token, @access_secret = options[:access]
    end

    @environment = options[:environment]
  end

  ##
  # generic user-specific GET request method that returns JSON

  def get resource
    resource = resource.to_s
    resource = "/#{resource}" unless resource =~ /^\//
    response = accessor.get(resource, headers)

    JSON.parse(response.body)
  end

  ##
  # organizations associated with this access

  def organizations
    return @organizations if defined?(@organizations)
    @organizations = MyJohnDeereApi::Request::Collection::Organizations.new(accessor).all
  end

  private

  ##
  # Returns an oAuth consumer which can be used to build requests

  def consumer
    return @consumer if defined?(@consumer)
    @consumer = MyJohnDeereApi::Consumer.new(@api_key, @api_secret, environment: environment)
  end

  ##
  # Returns an oAuth AccessToken object which can be used to make
  # user-specific API requests

  def accessor
    return @accessor if defined?(@accessor)
    @accessor = OAuth::AccessToken.new(consumer.user_get, access_token, access_secret)
  end

  def headers
    @headers ||= {accept: 'application/vnd.deere.axiom.v3+json'}
  end
end