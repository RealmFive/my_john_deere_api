require 'support/helper'

describe 'MyJohnDeereApi::Model' do
  describe 'loading dependencies' do
    it 'loads Model::Organization' do
      assert JD::Model::Organization
    end

    it 'loads Model::Field' do
      assert JD::Model::Field
    end

    it 'loads Model::Flag' do
      assert JD::Model::Flag
    end
  end
end
