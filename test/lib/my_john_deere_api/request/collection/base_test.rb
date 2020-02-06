require 'support/helper'

describe 'MyJohnDeereApi::Request::Collection::Base' do
  describe '#initialize(access_token)' do
    it 'accepts an access token' do
      collection = JD::Request::Collection::Base.new(accessor)
      assert_kind_of OAuth::AccessToken, collection.accessor
    end

    it 'accepts associations' do
      collection = JD::Request::Collection::Base.new(accessor, organization: organization_id)

      assert_kind_of Hash, collection.associations
      assert_equal organization_id, collection.associations[:organization]
    end
  end

  it 'uses the Enumerable module' do
    collection = JD::Request::Collection::Base.new(accessor)

    [:each, :first, :map, :detect, :select].each do |method_name|
      assert collection.respond_to?(method_name)
    end
  end
end