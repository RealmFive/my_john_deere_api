require 'oauth2'
require 'uri'
require 'json'

module MyJohnDeereApi
  autoload :VERSION,        'my_john_deere_api/version'
  autoload :Authorize,      'my_john_deere_api/authorize'
  autoload :Client,         'my_john_deere_api/client'
  autoload :Consumer,       'my_john_deere_api/consumer'
  autoload :Request,        'my_john_deere_api/request'
  autoload :Model,          'my_john_deere_api/model'
  autoload :Helpers,        'my_john_deere_api/helpers'
  autoload :Validators,     'my_john_deere_api/validators'

  require 'my_john_deere_api/errors'
  require 'my_john_deere_api/net_http_retry'
end