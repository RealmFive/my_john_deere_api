require 'support/helper'

describe 'MyJohnDeereApi::Helpers' do
  describe 'loading dependencies' do
    it 'loads Helpers::UriPath' do
      assert JD::Helpers::UriPath
    end
  end
end
