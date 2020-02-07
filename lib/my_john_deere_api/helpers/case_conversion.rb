require 'uri'

module MyJohnDeereApi::Helpers::CaseConversion
  private

  ##
  # convert a text or camelcase string to underscore

  def underscore(something)
    something = something.to_s if something.is_a?(Symbol)

    if something.is_a?(String)
      something.gsub(/([a-z])([A-Z])/, '\1_\2').gsub(/\s+/, '_').gsub(/_+/, '_').downcase
    elsif something.is_a?(Hash)
      something.transform_keys{ |key| underscore(key) }
    end
  end

  ##
  # convert text or underscored string to camelcase

  def camelize(something)
    something = something.to_s if something.is_a?(Symbol)

    if something.is_a?(String)
      list = something.strip.split(/[_\s]+/)

      # preserve case of the first element
      new_list = [list.shift]
      new_list += list.map(&:capitalize)

      new_list.join('')
    elsif something.is_a?(Hash)
      something.transform_keys{ |key| camelize(key) }
    end
  end
end