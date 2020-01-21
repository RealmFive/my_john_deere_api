class MyJohnDeereApi::Authorize
  attr_reader :api_key, :api_secret,
    :request_token, :request_secret,
    :access_token, :access_secret,
    :environment, :options

  DEFAULTS = {
    environment: :production
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
    @environment = options[:environment]
  end

  ##
  # Option a url which may be used to obtain a verification
  # code from the oauth server.

  def authorize_url
    return @authorize_url if defined?(@authorize_url)

    request_options = options.slice(:oauth_callback)

    requester = consumer.get_request_token(request_options)
    @request_token = requester.token
    @request_secret = requester.secret

    @authorize_url = requester.authorize_url(request_options)
  end

  ##
  # API consumer that makes non-user-specific GET requests

  def consumer
    return @consumer if defined?(@consumer)
    @consumer = MyJohnDeereApi::Consumer.new(@api_key, @api_secret, environment: environment).app_get
  end

  ##
  # Turn a verification code into access tokens. If this is
  # run from a separate process than the one that created
  # the initial RequestToken, the request token/secret
  # can be passed in.

  def verify(code, token=nil, secret=nil)
    token ||= request_token
    secret ||= request_secret

    requester = OAuth::RequestToken.new(consumer, token, secret)
    access_object = requester.get_access_token(oauth_verifier: code)
    @access_token = access_object.token
    @access_secret = access_object.secret
    nil
  end
end