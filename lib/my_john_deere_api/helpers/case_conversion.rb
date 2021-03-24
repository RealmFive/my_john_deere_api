require 'uri'

module MyJohnDeereApi::Helpers::CaseConversion
  private

  ##
  # convert a text or camelcase string to underscore

  def underscore(something)
    case something
    when Symbol, String
      something.to_s.gsub(/([a-z])([A-Z])/, '\1_\2').gsub(/\s+/, '_').gsub(/_+/, '_').downcase
    when Hash
      something.transform_keys{ |key| underscore(key) }
    when Array
      something.map{|element| underscore(element)}
    end
  end

  ##
  # convert text or underscored string to camelcase

  def camelize(something)
    case something
    when Symbol, String
      list = something.to_s.strip.split(/[_\s]+/)

      # preserve case of the first element
      new_list = [list.shift]
      new_list += list.map(&:capitalize)

      new_list.join('')
    when Hash
      something.transform_keys{ |key| camelize(key) }
    when Array
      something.map{|element| camelize(element)}
    end
  end
end