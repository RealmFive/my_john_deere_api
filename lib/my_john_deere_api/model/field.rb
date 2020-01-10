module MyJohnDeereApi
  class Model::Field
    include Helpers::UriPath

    attr_reader :name, :id, :links, :accessor

    ##
    # arguments:
    #
    # [record] a JSON object of type 'Field', returned from the API.
    #
    # [accessor (optional)] a valid oAuth Access Token. This is only
    #                       needed if further API requests are going
    #                       to be made, as is the case with *flags*.

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

    ##
    # Since the archived attribute is boolean, we reflect this in the
    # method name instead of using a standard attr_reader.

    def archived?
      @archived
    end

    ##
    # flags associated with this organization

    def flags
      raise AccessTokenError unless accessor

      return @flags if defined?(@flags)
      @flags = Request::Collection::Flags.new(accessor, organization: organization_id, field: id).all
    end

    private

    ##
    # Infer the organization_id from the 'self' link

    def organization_id
      return @organization_id if defined?(@organization_id)

      parts = links['self'].split('/')
      @organization_id = parts[parts.index('organizations') + 1]
    end
  end
end