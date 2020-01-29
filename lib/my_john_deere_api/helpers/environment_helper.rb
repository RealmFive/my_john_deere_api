require 'uri'

module MyJohnDeereApi
  module Helpers::EnvironmentHelper
    attr_reader :environment

    private

    ##
    # Intelligently set the environment

    def environment=(value)
      value = (value || :live).to_sym

      @environment = case value
      when :sandbox, :live
        value
      when :production
        :live
      else
        raise UnsupportedEnvironmentError, value
      end
    end
  end
end