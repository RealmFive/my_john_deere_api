module MyJohnDeereApi
  class Model::Field < Model::Base
    attr_reader :name

    ##
    # Since the archived attribute is boolean, we reflect this in the
    # method name instead of using a standard attr_reader.

    def archived?
      @archived
    end

    ##
    # flags associated with this organization

    def flags
      return @flags if defined?(@flags)
      @flags = Request::Collection::Flags.new(client, organization: organization_id, field: id)
    end

    private

    def map_attributes(record)
      @name = record['name']
      @archived = record['archived']
    end

    def expected_record_type
      'Field'
    end

    ##
    # Infer the organization_id from the 'self' link

    def organization_id
      return @organization_id if defined?(@organization_id)
      @organization_id = id_from_uri(links['self'], :organizations)
    end
  end
end