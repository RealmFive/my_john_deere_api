require 'support/helper'

describe 'JD::NetHttpRetry::MissingLocationHeaderError' do
  let(:klass) { JD::MissingLocationHeaderError }
  let(:response) { stub(response_content) }
  let(:response_content) { {code: '200', message: 'Success', body: '<p>accidental html response</p>'} }

  it 'inherits from StandardError' do
    error = klass.new(response)
    assert_kind_of StandardError, error
  end

  it 'accepts a response object, and includes pertinent info' do
    expected_message = response_content.to_json
    actual_message = klass.new(response).message

    assert_equal expected_message, actual_message
  end
end