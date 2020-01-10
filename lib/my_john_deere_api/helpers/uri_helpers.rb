require 'uri'

module MyJohnDeereApi::Helpers::UriHelpers
  private

  ##
  # extract just the path from the uri, excluding the platform prefix
  def uri_path(uri)
    URI.parse(uri).path.gsub(/^\/platform/, '')
  end

  ##
  # infer id from uri

  def id_from_uri(uri, label)
    parts = uri.split('/')
    parts[parts.index(label.to_s) + 1]
  end
end