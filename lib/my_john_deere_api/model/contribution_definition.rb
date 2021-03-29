module MyJohnDeereApi
  class Model::ContributionDefinition < Model::Base
    attr_reader :name

    private

    def map_attributes(record)
      @name = record['name']
    end

    def expected_record_type
      'ContributionDefinition'
    end
  end
end