module MyJohnDeereApi
  module ResponseHelpers
    def assert_created(response)
      assert_response(response, 201, 'Created')
    end

    def assert_no_content(response)
      assert_response(response, 204, 'No Content')
    end

    def assert_response(response, code, message)
      faraday_response = response.response

      assert_equal code, faraday_response.status
      assert_equal message, faraday_response.reason_phrase
    end
  end
end