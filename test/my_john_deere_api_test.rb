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

    it 'loads Request' do
      assert JD::Request
    end

    it 'loads Model' do
      assert JD::Model
    end

    it 'loads Helpers' do
      assert JD::Helpers
    end

    it 'loads Validators' do
      assert JD::Validators
    end
  end
end
