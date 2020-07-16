$LOAD_PATH << './lib'
require 'my_john_deere_api'
require 'net_http_retry'
require 'dotenv/load'

def client
  @client ||= MyJohnDeereApi::Client.new(ENV['API_KEY'], ENV['API_SECRET'], environment: :sandbox, access: [ENV['ACCESS_TOKEN'], ENV['ACCESS_SECRET']])
end
