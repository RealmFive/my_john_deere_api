module MyJohnDeereApi
  module LinkHelpers
    def link_for(label)
      record['links'].detect{|link| link['rel'] == label}['uri'].gsub('https://sandboxapi.deere.com', '')
    end

    def assert_link_for(object, attribute)
      attribute_underscore = attribute.to_s
      attribute_camelcase = attribute_underscore.gsub(%r{_(.)}){$1.upcase}

      assert_equal link_for(attribute_camelcase), object.links[attribute_underscore]
    end
  end
end