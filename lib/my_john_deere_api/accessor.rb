module MyJohnDeereApi
  class Accessor
    attr_reader :access_token

    REQUEST_METHODS = [:get, :post, :put, :delete] #[:get, :post, :put, :delete]

    def initialize(oauth_access_token)
      @access_token = oauth_access_token
    end

    def request(method_name, *args)
      result = access_token.send(method_name, *args)

      while result['retry-after']
        sleep result['retry-after'].to_i
        result = access_token.send(method_name, *args)
      end

      result
    end

    private

    def method_missing(method_name, *args, &block)
      if REQUEST_METHODS.include?(method_name)
        request(method_name, *args)
      else
        access_token.send(method_name, *args, &block)
      end
    end
  end
end

