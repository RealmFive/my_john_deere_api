require 'uri'

module MyJohnDeereApi::Helpers::UriPath
  def uri_path(uri)
    URI.parse(uri).path.gsub(/^\/platform/, '')
  end

  private :uri_path
end