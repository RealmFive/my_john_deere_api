require 'support/helper'
require 'yaml'
require 'json'

class UpdateBaseItem
  attr_reader :attributes

  def initialize
    @attributes = {
      name: 'Bob',
      age: 21
    }
  end
end

describe 'MyJohnDeereApi::Request::Update::Base' do
  let(:object) { JD::Request::Update::Base.new(accessor, item, attributes) }
  let(:item) { UpdateBaseItem.new }
  let(:attributes) { {} }

  describe '#initialize(access_token, item, attributes)' do
    it 'accepts an accessor, item and attributes' do
      assert_equal accessor, object.accessor
      assert_equal item, object.item
    end

    describe 'when a new attribute (ie, name) is passed in' do
      let(:attributes) { {name: 'John'} }

      it 'merges name with item attributes' do
        assert_equal attributes[:name], object.attributes[:name]
        assert_equal item.attributes[:age], object.attributes[:age]
      end
    end

    describe 'when a new attribute (ie, age) is passed in' do
      let(:attributes) { {age: 99} }

      it 'merges name with item attributes' do
        assert_equal item.attributes[:name], object.attributes[:name]
        assert_equal attributes[:age], object.attributes[:age]
      end
    end
  end

  describe '#headers' do
    it 'sets the accept and content-type headers' do
      object = JD::Request::Update::Base.new(accessor, item, attributes)
      headers = object.send(:headers)

      expected = 'application/vnd.deere.axiom.v3+json'

      assert_kind_of Hash, headers
      assert_equal expected, headers['Accept']
      assert_equal expected, headers['Content-Type']
    end
  end
end