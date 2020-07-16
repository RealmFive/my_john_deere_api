require 'net_http_retry/max_retries_exceeded_error'

module NetHttpRetry
  class Decorator
    attr_reader :object

    REQUEST_METHODS = [:get, :post, :put, :delete]

    RETRY_DELAY_EXPONENT = 2
    MAX_RETRIES = 12
    RETRIABLE_RESPONSE_CODES = ['429', '503']

    def initialize(object)
      @object = object
    end

    def request(method_name, *args)
      retries = 0
      result = object.send(method_name, *args)

      while RETRIABLE_RESPONSE_CODES.include?(result.code)
        if retries >= MAX_RETRIES
          raise MaxRetriesExceededError.new(method_name, "#{result.code} #{result.message}")
        end

        delay = [result['retry-after'].to_i, RETRY_DELAY_EXPONENT ** retries].max
        sleep(delay)

        result = object.send(method_name, *args)
        retries += 1
      end

      result
    end

    private

    def method_missing(method_name, *args, &block)
      if REQUEST_METHODS.include?(method_name)
        request(method_name, *args)
      else
        object.send(method_name, *args, &block)
      end
    end
  end
end
