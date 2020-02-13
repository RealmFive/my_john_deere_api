require 'support/helper'

module BaseValidatorTest
  class Base
    include JD::Validators::Base

    attr_reader :attributes

    def initialize(attributes)
      @attributes = attributes
    end
  end

  class Vanilla < Base
  end

  class WithRequiredAttributes < Base
    def required_attributes
      [:name]
    end
  end

  class WithCustomValidations < Base
    def validate_attributes
      errors[:name] = 'is not Bob' unless attributes[:name] == 'Bob'
    end
  end
end

describe 'MyJohnDeereApi::Validators::Base' do
  let(:klass) { BaseValidatorTest::Vanilla }
  let(:object) { klass.new(attributes) }
  let(:valid_attributes) { {name: 'Bob'} }
  let(:attributes) { valid_attributes }

  it 'exists' do
    assert klass
  end

  describe '#validate!' do
    it 'returns true when valid' do
      assert object.validate!
    end
  end

  describe 'with required attributes' do
    let(:klass) { BaseValidatorTest::WithRequiredAttributes }

    it 'returns true when valid' do
      assert object.validate!
    end

    describe 'without required attribute' do
      let(:attributes) { {} }

      it 'raises an error' do
        exception = assert_raises(JD::InvalidRecordError) { object.validate! }

        assert_includes exception.message, 'name is required'
        assert_includes object.errors[:name], 'is required'
      end

      describe 'with unrequired attributes' do
        let(:attributes) { valid_attributes.merge(age: 101) }

        it 'returns true' do
          assert object.validate!
        end
      end
    end
  end

  describe 'custom validations' do
    let(:klass) { BaseValidatorTest::WithCustomValidations }
    let(:attributes) { valid_attributes.merge(name: 'Bob') }

    it 'returns true when valid' do
      assert object.validate!
    end

    describe 'when custom validation fails' do
      let(:attributes) { valid_attributes.merge(name: 'Turtles') }

      it 'raises an error' do
        exception = assert_raises(JD::InvalidRecordError) { object.validate! }

        assert_includes exception.message, 'name is not Bob'
        assert_includes object.errors[:name], 'is not Bob'
      end
    end
  end
end