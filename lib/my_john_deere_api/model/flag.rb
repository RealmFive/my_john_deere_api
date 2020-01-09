require 'json'

module MyJohnDeereApi
  class Model::Flag
    include Helpers::CaseConversion
    include Helpers::UriPath

    attr_reader :id, :notes, :geometry, :links, :accessor

    ##
    # arguments:
    #
    # [record] a JSON object of type 'Flag', returned from the API.
    #
    # [accessor (optional)] a valid oAuth Access Token. This is only
    #                       needed if further API requests are going
    #                       to be made.

    def initialize(record, accessor = nil)
      @accessor = accessor

      @id = record['id']
      @notes = record['notes']
      @geometry =JSON.parse(record['geometry'])
      @proximity_alert_enabled = record['proximityAlertEnabled']
      @archived = record['archived']

      @links = {}

      record['links'].each do |association|
        @links[underscore(association['rel'])] = uri_path(association['uri'])
      end
    end

    ##
    # Since the archived attribute is boolean, we reflect this in the
    # method name instead of using a standard attr_reader.

    def archived?
      @archived
    end

    ##
    # Since the proximity_alert_enabled attribute is boolean, we reflect this
    # in the method name instead of using a standard attr_reader.

    def proximity_alert_enabled?
      @proximity_alert_enabled
    end
  end
end