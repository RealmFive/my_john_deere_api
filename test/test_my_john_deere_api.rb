require 'support/helper'

class MyJohnDeereApiTest < MiniTest::Test
  describe 'loading dependencies' do
    it 'loads VERSION' do
      assert JD::VERSION
    end

    it 'loads Authorize' do
      assert JD::Authorize
    end

    it 'loads Client' do
      assert JD::Client
    end

    it 'loads Consumer' do
      assert JD::Consumer
    end
  end
end
