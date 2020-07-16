require 'support/helper'

describe 'NetHttpRetry::Decorator' do
  REQUESTS = {
    get:    '/',
    post:   '/organizations/000000/assets',
    put:    '/assets/00000000-0000-0000-0000-000000000000',
    delete: '/assets/00000000-0000-0000-0000-000000000000'
  }

  REQUEST_METHODS = REQUESTS.keys

  let(:klass) { NetHttpRetry::Decorator }
  let(:object) { klass.new(mock, options) }

  let(:options) do
    {
      request_methods: request_methods,
      retry_delay_exponent: retry_delay_exponent,
      max_retries: max_retries,
      response_codes: response_codes
    }
  end

  let(:request_methods) { nil }
  let(:retry_delay_exponent) { nil }
  let(:max_retries) { nil }
  let(:response_codes) { nil }

  let(:retry_values) { [13, 17, 19, 23] }
  let(:exponential_retries) { (0..klass::DEFAULTS[:max_retries]-1).map{|i| 2 ** i} }

  it 'wraps a "net-http"-responsive object' do
    assert_kind_of OAuth::AccessToken, accessor.object
  end

  describe '#initialize' do
    describe 'when request methods are specified' do
      let(:request_methods) { [:banana, :fana, :fofana] }

      it 'uses the supplied values' do
        assert_equal request_methods, object.request_methods
      end
    end

    describe 'when request methods are not specified' do
      it 'uses the default values' do
        assert_equal klass::DEFAULTS[:request_methods], object.request_methods
      end
    end

    describe 'when retry_delay_exponent is specified' do
      let(:retry_delay_exponent) { 42 }

      it 'uses the supplied value' do
        assert_equal retry_delay_exponent, object.retry_delay_exponent
      end
    end

    describe 'when retry_delay_exponent is not specified' do
      it 'uses the default value' do
        assert_equal klass::DEFAULTS[:retry_delay_exponent], object.retry_delay_exponent
      end
    end

    describe 'when max_retries is specified' do
      let(:max_retries) { 42 }

      it 'uses the supplied value' do
        assert_equal max_retries, object.max_retries
      end
    end

    describe 'when max_retries is not specified' do
      it 'uses the default value' do
        assert_equal klass::DEFAULTS[:max_retries], object.max_retries
      end
    end

    describe 'when response_codes are specified' do
      let(:response_codes) { ['200', '201'] }

      it 'uses the supplied values' do
        assert_equal response_codes, object.response_codes
      end
    end

    describe 'when response_codes are specified as integers' do
      let(:response_codes) { [200, 201] }

      it 'uses the stringified versions of the supplied values' do
        assert_equal response_codes.map(&:to_s), object.response_codes
      end
    end

    describe 'when response_codes are not specified' do
      it 'uses the default values' do
        assert_equal klass::DEFAULTS[:response_codes], object.response_codes
      end
    end
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

        expected_error = "Max retries exceeded for #{request_method.to_s.upcase} request: 429 Too Many Requests"
        assert_equal expected_error, exception.message
      end
    end
  end
end