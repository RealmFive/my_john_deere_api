module NetHttpRetry
  ##
  # This error is used when a single request has exceeded
  # the number of retries allowed by NetHttpRetry::Decorator::MAX_RETRIES.

  class MaxRetriesExceededError < StandardError

    ##
    # argument is a string which describes the attempted request

    def initialize(request_method, response_message)
      message = "Max retries (#{NetHttpRetry::Decorator::MAX_RETRIES}) " +
                "exceeded for #{request_method.to_s.upcase} " +
                "request: #{response_message}"

      super(message)
    end
  end
end