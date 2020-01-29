module MyJohnDeereApi
  ##
  # This error is used when an unsupported environment has been requested.
  # Supported environments currently include :sandbox, :live, and :production
  # as a synonym for :live.

  class UnsupportedEnvironmentError < StandardError
    def initialize(environment = nil)
      message = if environment
        "The #{environment.inspect} environment is not supported."
      else
        'This environment is not supported.'
      end

      super(message)
    end
  end
end