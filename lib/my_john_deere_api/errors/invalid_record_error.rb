module MyJohnDeereApi
  ##
  # This error is used in a context that will fail in the absence of
  # a valid oAuth access token. We have classes that may only need 
  # access tokens for some use cases.

  class InvalidRecordError < StandardError

    ##
    # argument is a hash of attributes and their error messages,
    # which will be built into the raised message.

    def initialize(errors = {})
      message = 'Record is invalid'

      unless errors.empty?
        attribute_messages = []

        errors.each do |attribute, message|
          attribute_messages << "#{attribute} #{message}"
        end

        message = "#{message}: #{attribute_messages.join('; ')}"
      end

      super(message)
    end
  end
end