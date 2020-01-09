require 'uri'

module MyJohnDeereApi
  class Model::Organization
    include Helpers::UriPath

    attr_reader :name, :type, :id, :links, :accessor

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

    def member?
      @member
    end

    ##
    # fields associated with this organization

    def fields
      raise AccessTokenError unless accessor

      return @fields if defined?(@fields)
      @fields = MyJohnDeereApi::Request::Fields.new(accessor, organization: id).all
    end
  end
end