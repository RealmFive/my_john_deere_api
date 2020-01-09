module MyJohnDeereApi
  class Model::Field
    include Helpers::UriPath

    attr_reader :name, :id, :links, :accessor

    def initialize(record, accessor = nil)
      @accessor = accessor

      @name = record['name']
      @id = record['id']
      @archived = record['archived']

      @links = {}

      record['links'].each do |association|
        @links[association['rel']] = uri_path(association['uri'])
      end
    end

    def archived?
      @archived
    end
  end
end