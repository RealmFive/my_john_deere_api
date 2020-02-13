module MyJohnDeereApi
  ##
  # This is a mix-in for Create/Update Reqest classes. It assumes that
  # the class in question has a hash of attributes that will be passed
  # to the request.
  #
  # This module creates the errors hash as a reader. The key of the hash
  # is the attribute name, and the value is an array of error messages
  # for that attribute. Follow this format when defining custom
  # validations in the `validate_attributes` method.

  module Validators::Base
    attr_reader :errors

    ##
    # Raises an error if the record is invalid. Passes the errors hash
    # to the error, in order to build a useful message string.

    def validate!
      raise(InvalidRecordError, errors) unless valid?
      true
    end
    ##

    # Runs validations, adding to the errors hash as needed. Returns true
    # if the errors hash is still empty after all validations have been run.

    def valid?
      return @is_valid if defined?(@is_valid)

      @errors = {}
      validate_required
      validate_attributes

      @is_valid = errors.empty?
    end

    private

    ##
    # Validates required attributes

    def validate_required
      required_attributes.each do |attr|
        errors[attr] = 'is required' unless attributes[attr]
      end
    end

    ##
    # Attributes that must be specified, override in child module if needed

    def required_attributes
      []
    end

    ##
    # Handle any custom validation for this class, override in child module if needed.
    #
    # Add messages to errors hash with the attribute name as the key, and an array
    # of error messages as the value. 

    def validate_attributes
      # Example:
      # errors[:name] = "can't be blank" if errors[:name].size == 0
    end
  end
end