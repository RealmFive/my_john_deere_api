require 'json'

module MyJohnDeereApi
  class Model::Flag < Model::Base
    attr_reader :notes, :geometry

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

    private

    def map_attributes(record)
      @notes = record['notes']
      @geometry =JSON.parse(record['geometry'])
      @proximity_alert_enabled = record['proximityAlertEnabled']
      @archived = record['archived']
    end
  end
end