require 'uri'

module MyJohnDeereApi
  class Model::Organization < Model::Base
    attr_reader :name, :type

    ##
    # Since the member attribute is boolean, we reflect this in the
    # method name instead of using a standard attr_reader.

    def member?
      @member
    end

    ##
    # fields associated with this organization

    def fields
      raise AccessTokenError unless accessor

      return @fields if defined?(@fields)
      @fields = MyJohnDeereApi::Request::Collection::Fields.new(accessor, organization: id)
    end

    ##
    # assets associated with this organization

    def assets
      raise AccessTokenError unless accessor

      return @assets if defined?(@assets)
      @assets = MyJohnDeereApi::Request::Collection::Assets.new(accessor, organization: id)
    end

    private

    def map_attributes(record)
      @name = record['name']
      @type = record['type']
      @member = record['member']
    end

    def expected_record_type
      'Organization'
    end
  end
end