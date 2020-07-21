module MyJohnDeereApi
  module NetHttpRetry
    class Decorator
      attr_reader :object, :request_methods, :retry_delay_exponent, :max_retries, :retry_codes

      DEFAULTS = {
        request_methods:      [:get, :post, :put, :delete],
        retry_delay_exponent: 2,
        max_retries: 12,
        retry_codes: ['429', '503']
      }

      def initialize(object, options={})
        @object = object

        [:request_methods, :retry_delay_exponent, :max_retries].each do |option|
          instance_variable_set(:"@#{option}", options[option] || DEFAULTS[option])
        end

        @retry_codes = (options[:retry_codes] || DEFAULTS[:retry_codes]).map(&:to_s)
      end

      def request(method_name, *args)
        retries = 0
        result = object.send(method_name, *args)

        while retry_codes.include?(result.code)
          if retries >= max_retries
            raise MaxRetriesExceededError.new(method_name, "#{result.code} #{result.message}")
          end

          delay = [result['retry-after'].to_i, retry_delay_exponent ** retries].max
          sleep(delay)

          result = object.send(method_name, *args)
          retries += 1
        end

        result
      end

      private

      def method_missing(method_name, *args, &block)
        if request_methods.include?(method_name)
          request(method_name, *args)
        else
          object.send(method_name, *args, &block)
        end
      end
    end
  end
end