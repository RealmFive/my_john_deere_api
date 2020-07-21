module MyJohnDeereApi
  ##
  # This error is used when an HTTP response does not contain
  # an expected Location header.

  class MissingLocationHeaderError < StandardError

    ##
    # argument is a Net:HTTP response object

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