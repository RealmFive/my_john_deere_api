module MyJohnDeereApi
  class Accessor
    attr_reader :access_token

    REQUEST_METHODS = [:get, :post, :put, :delete]

    RETRY_DELAY_EXPONENT = 2
    MAX_RETRIES = 12
    RETRIABLE_RESPONSE_CODES = ['429', '503']

    def initialize(oauth_access_token)
      @access_token = oauth_access_token
    end

    def request(method_name, *args)
      retries = 0
      result = access_token.send(method_name, *args)

      while RETRIABLE_RESPONSE_CODES.include?(result.code)
        if retries >= MAX_RETRIES
          raise MaxRetriesExceededError.new(method_name, "#{result.code} #{result.message}")
        end

        delay = [result['retry-after'].to_i, RETRY_DELAY_EXPONENT ** retries].max
        sleep(delay)

        result = access_token.send(method_name, *args)
        retries += 1
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

