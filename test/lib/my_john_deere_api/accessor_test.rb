require 'support/helper'

describe 'MyJohnDeereApi::Accessor' do
  let(:retry_values) { [13, 17, 19, 23] }

  it 'wraps an oauth access token' do
    assert_kind_of OAuth::AccessToken, accessor.access_token
  end

  it "honors retry-after headers in GET requests" do
    retry_values.each do |retry_seconds|
      accessor.expects(:sleep).with(retry_seconds)
    end

    VCR.use_cassette('get_retry') do
      accessor.get('/')
    end
  end

  it "honors retry-after headers in POST requests" do
    retry_values.each do |retry_seconds|
      accessor.expects(:sleep).with(retry_seconds)
    end

    VCR.use_cassette('post_retry') do
      accessor.post('/organizations/000000/assets')
    end
  end

  it "honors retry-after headers in PUT requests" do
    retry_values.each do |retry_seconds|
      accessor.expects(:sleep).with(retry_seconds)
    end

    VCR.use_cassette('put_retry') do
      accessor.put('/assets/00000000-0000-0000-0000-000000000000')
    end
  end

  it "honors retry-after headers in DELETE requests" do
    retry_values.each do |retry_seconds|
      accessor.expects(:sleep).with(retry_seconds)
    end

    VCR.use_cassette('delete_retry') do
      accessor.delete('/assets/00000000-0000-0000-0000-000000000000')
    end
  end
end