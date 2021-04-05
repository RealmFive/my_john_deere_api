require 'uri'

module MyJohnDeereApi
  class Model::Organization < Model::Base
    attr_reader :name, :type

    ##
    # Since the member attribute is boolean, we reflect this in the
    # method name instead of using a standard attr_reader.

    def member?
      @member
    end

    ##
    # fields associated with this organization

    def fields
      return @fields if defined?(@fields)
      @fields = MyJohnDeereApi::Request::Collection::Fields.new(client, organization: id)
    end

    ##
    # assets associated with this organization

    def assets
      return @assets if defined?(@assets)
      @assets = MyJohnDeereApi::Request::Collection::Assets.new(client, organization: id)
    end

    ##
    # whether this organization still needs to be approved in JD "connections"

    def needs_connection?
      links.key?('connections')
    end

    ##
    # the URI for JD connections page, if available

    def connections_uri
      record['links'].detect{|link| link['rel'] == 'connections'}&.fetch('uri')
    end

    private

    def map_attributes(record)
      @name = record['name']
      @type = record['type']
      @member = record['member']
    end

    def expected_record_type
      'Organization'
    end
  end
end
