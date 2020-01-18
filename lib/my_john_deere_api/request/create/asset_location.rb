require 'date'

module MyJohnDeereApi
  class Request::Create::AssetLocation < Request::Create::Base
    private

    ##
    # Request body

    def request_body
      return @body if defined?(@body)

      @body = [
        {
          timestamp: timestamp,
          geometry: geometry,
          measurementData: attributes[:measurement_data]
        }
      ]
    end

    ##
    # Parsed timestamp

    def timestamp
      return @timestamp if defined?(@timestamp)

      @timestamp = attributes[:timestamp].is_a?(String) ?
        attributes[:timestamp] :
        attributes[:timestamp].strftime('%Y-%m-%dT%H:%M:%SZ')
    end

    ##
    # Parse geometry

    def geometry
      return @geometry if defined?(@geometry)

      @geometry = attributes[:geometry].is_a?(String) ?
        attributes[:geometry] :
        attributes[:geometry].to_json
    end

    ##
    # Path supplied to API

    def resource
      @resource ||= "/assets/#{attributes[:asset_id]}/locations"
    end

    ##
    # Required attributes for this class

    def required_attributes
      [:asset_id, :timestamp, :geometry, :measurement_data]
    end

    ##
    # Retrieve newly created record

    def fetch_record
      # There is no way to fetch a single location by id, because locations
      # don't have IDs. You have to fetch them in bulk via the asset, but
      # there could be thousands. We limit to just the record created with
      # our timestamp, which must be unique.

      path = response['location'].split('/platform').last
      start_date = timestamp_add(timestamp, -1)
      end_date = timestamp_add(timestamp, 1)
      path += "?startDate=#{start_date}&endDate=#{end_date}"
      result = accessor.get(path, headers)

      parsed_stamp = DateTime.parse(timestamp)

      JSON.parse(result.body)['values'].detect do |record|
        parsed_stamp == DateTime.parse(record['timestamp'])
      end
    end

    ##
    # Create a new timestamp adjusted by X minutes

    def timestamp_add(timestamp, seconds)
      stamp = DateTime.parse(timestamp).to_time + seconds
      stamp.to_datetime.strftime('%Y-%m-%dT%H:%M:%SZ')
    end

    ##
    # This is the class used to model the data

    def model
      Model::AssetLocation
    end

    ##
    # Custom validations for this class

    def validate_attributes
      validate_measurement_data
    end

    def validate_measurement_data
      unless attributes[:measurement_data].is_a?(Array)
        errors[:measurement_data] ||= 'must be an array'
        return
      end

      attributes[:measurement_data].each do |measurement|
        [:name, :value, :unit].each do |attr|
          unless measurement.has_key?(attr)
            errors[:measurement_data] ||= "must include #{attr}"
            return
          end
        end
      end
    end
  end
end