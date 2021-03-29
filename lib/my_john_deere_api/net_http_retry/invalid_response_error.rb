module MyJohnDeereApi
  module NetHttpRetry
    ##
    # This error is used when a single request has exceeded
    # the number of retries allowed by NetHttpRetry::Decorator::MAX_RETRIES.

    class InvalidResponseError < StandardError

      ##
      # argument is a string which describes the attempted request

      def initialize(response)
        message = {
          code: response.status,
          message: response.response.reason_phrase,
          body: response.body,
        }.to_json

        super(message)
      end
    end
  end
end