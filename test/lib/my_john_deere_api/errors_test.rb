require 'support/helper'

describe 'MyJohnDeereApi Errors' do
  describe 'loading dependencies' do
    it 'loads InvalidRecordError' do
      assert JD::InvalidRecordError
    end

    it 'loads NotYetImplementedError' do
      assert JD::NotYetImplementedError
    end

    it 'loads TypeMismatchError' do
      assert JD::TypeMismatchError
    end

    it 'loads UnsupportedEnvironmentError' do
      assert JD::UnsupportedEnvironmentError
    end
  end
end
