module MyJohnDeereApi
  class Model::Base
    include Helpers::CaseConversion
    include Helpers::UriHelpers

    attr_reader :id, :record_type, :accessor, :links

    ##
    # arguments:
    #
    # [record] a JSON object of type 'Field', returned from the API.
    #
    # [accessor (optional)] a valid oAuth Access Token. This is only
    #                       needed if further API requests are going
    #                       to be made, as is the case with *flags*.

    def initialize(record, accessor = nil)
      verify_record_type(record['@type'])

      @id = record['id']
      @record_type = record['@type']
      @accessor = accessor

      map_attributes(record)

      @links = {}

      record['links'].each do |association|
        @links[underscore(association['rel'])] = uri_path(association['uri'])
      end
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
  end
end