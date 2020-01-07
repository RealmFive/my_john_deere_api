require 'rubygems'
require 'vcr'
require 'webmock'
require 'dotenv/load'
require 'minitest/autorun'
require 'my_john_deere_api'

# shortcut for long module name
JD = MyJohnDeereApi

API_KEY = ENV['API_KEY']
API_SECRET = ENV['API_SECRET']

TOKEN_PATTERN = /^[0-9a-z\-]+$/
SECRET_PATTERN = /^[0-9A-Za-z\-+=\/]+$/

VCR.configure do |config|
  config.cassette_library_dir = 'test/support/vcr'
  config.hook_into :webmock
end