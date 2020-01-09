require 'uri'

module MyJohnDeereApi
  class Model::Organization
    include Helpers::UriPath

    attr_reader :name, :type, :id, :links

    def initialize(record)
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
  end
end