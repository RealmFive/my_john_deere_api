require 'support/helper'

describe 'MyJohnDeereApi::Request::Collection::Base' do
  let(:klass) { JD::Request::Collection::Base }

  describe '#initialize(client)' do
    it 'accepts a client' do
      collection = klass.new(client)
      assert_equal client, collection.client
    end

    it 'accepts associations' do
      collection = klass.new(client, organization: organization_id)

      assert_kind_of Hash, collection.associations
      assert_equal organization_id, collection.associations[:organization]
    end
  end

  it 'uses the Enumerable module' do
    collection = klass.new(client)

    [:each, :first, :map, :detect, :select].each do |method_name|
      assert collection.respond_to?(method_name)
    end
  end
end