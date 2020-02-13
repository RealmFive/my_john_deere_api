module MyJohnDeereApi::Validators
  module AssetLocation
    include Base

    private

    def required_attributes
      [:asset_id, :timestamp, :geometry, :measurement_data]
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