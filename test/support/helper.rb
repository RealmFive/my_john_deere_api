require 'rubygems'
require 'vcr'
require 'webmock'
require 'dotenv/load'
require 'minitest/autorun'
require 'my_john_deere_api'

# shortcut for long module name
JD = MyJohnDeereApi

VCR.configure do |config|
  config.cassette_library_dir = 'test/support/vcr'
  config.hook_into :webmock
end