module MyJohnDeereApi
  class Model::Base
    include Helpers::CaseConversion
    include Helpers::UriHelpers

    attr_reader :id, :record, :record_type, :client, :links

    ##
    # arguments:
    #
    # [client] the client, because it contains all the config info.
    #          The alternative would be a true Config block, but then
    #          settings would be app-wide. This allows one app to have
    #          multiple clients with different settings.
    #
    # [record] a JSON object of type 'Field', returned from the API.

    def initialize(client, record)
      verify_record_type(record['@type'])

      @id = record['id']
      @record = record
      @record_type = record['@type']
      @client = client
      @unsaved = false

      map_attributes(record)

      @links = {}

      record['links'].each do |association|
        @links[underscore(association['rel'])] = uri_path(association['uri'])
      end
    end

    ##
    # The client accessor

    def accessor
      return @accessor if defined?(@accessor)
      @accessor = client&.accessor
    end

    private

    ##
    # This method receives the full record hash and extracts whatever extra
    # attributes are needed for the given base class. This is intended to
    # be overridden by child classes instead of monkeypatching #initialize.

    def map_attributes(record)

    end

    ##
    # Expected record type. Override in child classes.

    def expected_record_type
      'Base'
    end

    ##
    # Raise an error if this is not the type of record we expect to receive

    def verify_record_type(type)
      unless type == expected_record_type
        raise TypeMismatchError, "Expected record of type '#{expected_record_type}', but received type '#{type}'"
      end
    end

    ##
    # Mark as unsaved, so we know to save it later

    def mark_as_unsaved
      @unsaved = true
    end

    ##
    # Mark as saved, so we don't try to save it later

    def mark_as_saved
      @unsaved = false
    end

    ##
    # Are changes to this model synced with JD?
    def saved?
      !@unsaved
    end

    ##
    # Are there pending changes to send to JD?

    def unsaved?
      @unsaved
    end
  end
end