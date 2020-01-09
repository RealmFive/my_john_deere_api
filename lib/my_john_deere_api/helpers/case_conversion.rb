require 'uri'

module MyJohnDeereApi::Helpers::CaseConversion
  ##
  # convert a text or camelcase string to underscore

  def underscore(string)
    string.gsub(/([a-z])([A-Z])/, '\1_\2').gsub(/\s+/, '_').gsub(/_+/, '_').downcase
  end

  private :underscore

  ##
  # convert text or underscored string to camelcase

  def camelize(string)
    list = string.strip.split(/[_\s]+/)

    # preserve case of the first element
    new_list = [list.shift]
    new_list += list.map(&:capitalize)

    new_list.join('')
  end

  private :camelize
end