require 'json'

module MyJohnDeereApi
  class Model::AssetLocation
    include Helpers::UriHelpers

    attr_reader :accessor, :timestamp, :geometry, :measurement_data, :links

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

      @timestamp = record['timestamp']
      @geometry = JSON.parse(record['geometry'])
      @measurement_data = record['measurementData']
      @links = {}
    end
  end
end