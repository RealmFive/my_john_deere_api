require 'support/helper'

describe 'MyJohnDeereApi::Model' do
  describe 'loading dependencies' do
    it 'loads Model::Organization' do
      assert JD::Model::Organization
    end
  end
end
