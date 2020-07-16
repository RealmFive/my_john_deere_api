require 'support/helper'

describe 'NetHttpRetry::Accessor' do
  REQUESTS = {
    get:    '/',
    post:   '/organizations/000000/assets',
    put:    '/assets/00000000-0000-0000-0000-000000000000',
    delete: '/assets/00000000-0000-0000-0000-000000000000'
  }

  REQUEST_METHODS = REQUESTS.keys

  let(:retry_values) { [13, 17, 19, 23] }
  let(:exponential_retries) { (0..max_retries-1).map{|i| 2 ** i} }
  let(:max_retries) { NetHttpRetry::Accessor::MAX_RETRIES }

  it 'wraps an oauth access token' do
    assert_kind_of OAuth::AccessToken, accessor.access_token
  end

  describe "honors Retry-After headers" do
    REQUEST_METHODS.each do |request_method|
      it "in #{request_method.to_s.upcase} requests" do
        retry_values.each do |retry_seconds|
          accessor.expects(:sleep).with(retry_seconds)
        end

        VCR.use_cassette("accessor/#{request_method}_retry") do
          accessor.send(request_method, REQUESTS[request_method])
        end
      end
    end
  end

  describe 'employs exponential wait times for automatic retries' do
    REQUEST_METHODS.each do |request_method|
      it "in #{request_method.to_s.upcase} requests" do
        exponential_retries[0,8].each do |retry_seconds|
          accessor.expects(:sleep).with(retry_seconds)
        end

        VCR.use_cassette("accessor/#{request_method}_failed") do
          accessor.send(request_method, REQUESTS[request_method])
        end
      end
    end
  end

  describe 'when Retry-After is shorter than exponential wait time' do
    REQUEST_METHODS.each do |request_method|
      it "chooses longer exponential time in #{request_method.to_s.upcase} requests" do
        exponential_retries[0,4].each do |retry_seconds|
          accessor.expects(:sleep).with(retry_seconds)
        end

        VCR.use_cassette("accessor/#{request_method}_retry_too_soon") do
          accessor.send(request_method, REQUESTS[request_method])
        end
      end
    end
  end

  describe 'when max retries have been reached' do
    REQUEST_METHODS.each do |request_method|
      it "returns an error for #{request_method.to_s.upcase} requests" do
        exponential_retries.each do |retry_seconds|
          accessor.expects(:sleep).with(retry_seconds)
        end

        exception = assert_raises(NetHttpRetry::MaxRetriesExceededError) do
          VCR.use_cassette("accessor/#{request_method}_max_failed") do
            accessor.send(request_method, REQUESTS[request_method])
          end
        end

        expected_error = "Max retries (#{max_retries}) exceeded for #{request_method.to_s.upcase} request: 429 Too Many Requests"
        assert_equal expected_error, exception.message
      end
    end
  end
end