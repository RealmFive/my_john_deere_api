module MyJohnDeereApi::Validators
  module Asset
    include Base

    VALID_CATEGORIES = {
      'DEVICE' => {
        'SENSOR' => ['GRAIN_BIN', 'ENVIRONMENTAL', 'IRRIGATION_PIVOT', 'OTHER']
      },

      'EQUIPMENT' => {
        'MACHINE' => ['PICKUP_TRUCK', 'UTILITY_VEHICLE'],
        'OTHER' => ['ANHYDROUS_AMMONIA_TANK', 'NURSE_TRUCK', 'NURSE_WAGON', 'TECHNICIAN_TRUCK']
      },
    }

    private

    def required_attributes
      [:organization_id, :title]
    end

    def validate_attributes
      unless valid_categories?(attributes[:asset_category], attributes[:asset_type], attributes[:asset_sub_type])
        errors[:asset_category] = 'requires valid combination of category/type/subtype'
      end
    end

    ##
    # Returns boolean, true if this combination is valid

    def valid_categories?(category, type, subtype)
      VALID_CATEGORIES.dig(category, type).to_a.include?(subtype)
    end
  end
end