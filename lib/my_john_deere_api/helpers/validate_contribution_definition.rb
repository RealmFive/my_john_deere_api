require 'uri'

module MyJohnDeereApi
  module Helpers::ValidateContributionDefinition
    private

    ##
    # Raise an error if contribution_definition_id is missing

    def validate_contribution_definition
      if client.contribution_definition_id.nil?
        raise MissingContributionDefinitionIdError
      end

      true
    end
  end
end