require 'date'

module MyJohnDeereApi
  class Request::Create::AssetLocation < Request::Create::Base
    include Validators::AssetLocation

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
    # Retrieve newly created record

    def fetch_record
      # There is no endpoint to fetch a single location by id. We have to fetch
      # them in bulk via the asset, but there could be thousands. We limit the 
      # request to just the first record from the location list endpoint, since
      # locations are returned newest to oldest.

      path = location_header + '?count=1'
      result = accessor.get(path, headers)

      JSON.parse(result.body)['values'].first
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
  end
end