require 'uri'

module MyJohnDeereApi
  class Model::Organization
    include Helpers::UriHelpers

    attr_reader :name, :type, :id, :links, :accessor

    ##
    # arguments:
    #
    # [record] a JSON object of type 'Organization', returned from the API.
    #
    # [accessor (optional)] a valid oAuth Access Token. This is only
    #                       needed if further API requests are going
    #                       to be made, as is the case with *fields*.

    def initialize(record, accessor = nil)
      @accessor = accessor

      @name = record['name']
      @type = record['type']
      @id = record['id']
      @member = record['member']

      @links = {}

      record['links'].each do |association|
        @links[association['rel']] = uri_path(association['uri'])
      end
    end

    ##
    # Since the member attribute is boolean, we reflect this in the
    # method name instead of using a standard attr_reader.

    def member?
      @member
    end

    ##
    # fields associated with this organization

    def fields
      raise AccessTokenError unless accessor

      return @fields if defined?(@fields)
      @fields = MyJohnDeereApi::Request::Collection::Fields.new(accessor, organization: id).all
    end
  end
end