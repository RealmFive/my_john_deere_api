$LOAD_PATH << './lib'
require 'my_john_deere_api'
require 'dotenv/load'

client = MyJohnDeereApi::Client.new(ENV['API_KEY'], ENV['API_SECRET'], environment: :sandbox, access: [ENV['ACCESS_TOKEN'], ENV['ACCESS_KEY']])

