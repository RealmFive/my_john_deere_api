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

ACCESS_TOKEN = ENV['ACCESS_TOKEN']
ACCESS_SECRET = ENV['ACCESS_SECRET']

TOKEN_PATTERN = /^[0-9a-z\-]+$/
SECRET_PATTERN = /^[0-9A-Za-z\-+=\/]+$/

VCR.configure do |config|
  config.cassette_library_dir = 'test/support/vcr'
  config.hook_into :webmock
end

class Minitest::Spec
  class << self
    def inherits_from klass
      it "inherits from #{klass}" do
        public_methods = Hash.new([]).merge({
          JD::Request::Create::Base => [:request, :object, :valid?, :validate!],
          JD::Request::Collection::Base => [:each, :all, :count],
        })

        assert_kind_of klass, object

        public_methods[klass].each do |method_name|
          assert object.respond_to?(method_name)
        end
      end
    end
  end
end