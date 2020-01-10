require 'support/helper'

class CaseConversionHelperSample
  include JD::Helpers::CaseConversion
end

describe 'Helpers::CaseConversion' do
  let(:object) { CaseConversionHelperSample.new }

  describe '#underscore' do
    it 'converts from camelcase' do
      string = object.send(:underscore, 'camelCaseExample')
      assert_equal 'camel_case_example', string
    end

    it 'handles leading uppercase' do
      string = object.send(:underscore, 'CamelCaseExample')
      assert_equal 'camel_case_example', string
    end

    it 'converts spaces to underscores' do
      string = object.send(:underscore, 'camel case Example')
      assert_equal 'camel_case_example', string
    end

    it 'removes duplicate underscores after processing' do
      string = object.send(:underscore, 'camel  Case     Example')
      assert_equal 'camel_case_example', string
    end

    it 'is a private method' do
      assert_raises(NoMethodError) { object.underscore('test') }
    end
  end

  describe '#camelize' do
    it 'converts from underscored' do
      string = object.send(:camelize, 'this_is_a_test')
      assert_equal 'thisIsATest', string
    end

    it 'converts from spaced' do
      string = object.send(:camelize, 'this is a test')
      assert_equal 'thisIsATest', string
    end

    it 'honors original capitalization' do
      string = object.send(:camelize, 'This is a test')
      assert_equal 'ThisIsATest', string
    end

    it 'is a private method' do
      assert_raises(NoMethodError) { object.camelize('test') }
    end
  end
end
