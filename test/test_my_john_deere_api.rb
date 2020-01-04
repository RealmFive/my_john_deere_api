require 'minitest/autorun'
require 'my_john_deere_api'

class MyJohnDeereApiTest < MiniTest::Test
  describe 'VERSION' do
    it 'conforms to the semantic version format' do
      assert_match /^\d+\.\d+\.\d+$/, MyJohnDeereApi::VERSION
    end
  end
end
