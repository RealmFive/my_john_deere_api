require 'support/helper'

describe 'JD::NetHttpRetry::InvalidResponseError' do
  let(:klass) { JD::NetHttpRetry::InvalidResponseError }
  let(:response) { stub(response_content) }

  let(:faraday_response) do
    stub(
      status: '123',
      reason_phrase: 'failed',
      body: 'body'
    )
  end

  let(:response_content) do
    {
      status: faraday_response.status,
      body: faraday_response.body,
      response: faraday_response
    }
  end

  it 'inherits from StandardError' do
    error = klass.new(response)
    assert_kind_of StandardError, error
  end

  it 'accepts a response object, and includes pertinent info' do
    expected_message = {
      code: faraday_response.status,
      message: faraday_response.reason_phrase,
      body: faraday_response.body
    }.to_json

    actual_message = klass.new(response).message

    assert_equal expected_message, actual_message
  end
end