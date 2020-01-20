require 'date'

module MyJohnDeereApi
  class Request::Create::AssetLocation < Request::Create::Base
    private

    ##
    # Set defaults and generate some attributes from others.
    # Overridden from parent class.

    def process_attributes
      process_timestamp
      process_geometry
    end

    ##
    # Request body

    def request_body
      return @body if defined?(@body)

      @body = [{
        timestamp: attributes[:timestamp],
        geometry: attributes[:geometry],
        measurementData: attributes[:measurement_data]
      }]
    end

    ##
    # Custom-process timestamp

    def process_timestamp
      attributes[:timestamp] ||= Time.now.utc

      attributes[:timestamp] = attributes[:timestamp].is_a?(String) ?
        attributes[:timestamp] :
        attributes[:timestamp].strftime('%Y-%m-%dT%H:%M:%SZ')
    end

    ##
    # Custom-process geometry

    def process_geometry
      attributes[:geometry] = if attributes[:geometry]
        attributes[:geometry].is_a?(String) ?
          attributes[:geometry] :
          attributes[:geometry].to_json
      elsif attributes[:coordinates]
        geometry_from_coordinates
      end
    end

    ##
    # Convert just coordinates into valid geometry hash

    def geometry_from_coordinates
      {
        type: 'Feature',
        geometry: {
          geometries: [
            coordinates: attributes[:coordinates],
            type: 'Point'
          ],
          type: 'GeometryCollection'
        }
      }.to_json
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

      # API will only accept a timestamp *range*, and the start must be lower
      # than the end. We buffer start/end times by one second, then find the
      # exact match.
      start_date = timestamp_add(attributes[:timestamp], -1)
      end_date = timestamp_add(attributes[:timestamp], 1)
      path += "?startDate=#{start_date}&endDate=#{end_date}"

      result = accessor.get(path, headers)

      # Timestamps are returned with seconds in decimals, even though these 
      # are always zero. So we compare actual DateTime objects parsed from
      # the timestamp strings.
      parsed_stamp = DateTime.parse(attributes[:timestamp])

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