module MyJohnDeereApi
  module NetHttpRetry
    ##
    # This error is used when an unexpected response code
    # is returned from JD.

    class InvalidResponseError < StandardError

      ##
      # argument is a Net::HTTP response object

      def initialize(response)
        message = {
          code: response.code,
          message: response.message,
          body: response.body,
        }.to_json

        super(message)
      end
    end
  end
end