module MyJohnDeereApi
  class Request::Create::Asset < Request::Create::Base
    attr_reader :accessor, :attributes, :errors

    VALID_CATEGORIES = {
      'DEVICE' => {
        'SENSOR' => ['GRAIN_BIN', 'ENVIRONMENTAL', 'IRRIGATION_PIVOT', 'OTHER']
      },

      'EQUIPMENT' => {
        'MACHINE' => ['PICKUP_TRUCK', 'UTILITY_VEHICLE'],
        'OTHER' => ['ANHYDROUS_AMMONIA_TANK', 'NURSE_TRUCK', 'NURSE_WAGON', 'TECHNICIAN_TRUCK']
      },
    }

    def initialize(accessor, attributes)
      @accessor = accessor
      @attributes = attributes
      @errors = {}
    end

    ##
    # Raises an error if the record is invalid. Passes the errors hash
    # to the error, in order to build a useful message string.

    def validate!
      raise(InvalidRecordError, errors) unless valid?
    end

    ##
    # Runs validations, adding to the errors hash as needed. Returns true
    # if the errors hash is still empty after all validations have been run.

    def valid?
      return @valid if defined?(@valid)

      validate_required

      unless valid_categories?(attributes[:category], attributes[:type], attributes[:subtype])
        errors[:category] = 'requires valid combination of category/type/subtype'
      end

      @valid = errors.empty?
    end

    private

    ##
    # These attributes will flag the record as invalid if not included

    def required_attributes
      [:organization_id, :contribution_definition_id, :title]
    end

    ##
    # Validates required attributes

    def validate_required
      required_attributes.each do |attr|
        errors[attr] = 'is required' unless attributes.keys.include?(attr)
      end
    end

    ##
    # Returns boolean, true if this combination is valid

    def valid_categories?(category, type, subtype)
      VALID_CATEGORIES.dig(category, type).to_a.include?(subtype)
    end
  end
end