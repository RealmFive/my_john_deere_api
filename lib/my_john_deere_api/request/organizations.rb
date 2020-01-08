require 'json'

module MyJohnDeereApi::Request
  class Organizations < Collection
    ##
    # The resource path for the first page in the collection

    def resource
      '/organizations'
    end
  end
end