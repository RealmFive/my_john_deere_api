require 'support/helper'

class CaseConversionHelperSample
  include JD::Helpers::CaseConversion

  def test
    'test'
  end
end

describe 'Helpers::CaseConversion' do
  let(:object) { CaseConversionHelperSample.new }

  describe '#underscore' do
    it 'converts from camelcase' do
      string = object.send(:underscore, 'camelCaseExample')
      assert_equal 'camel_case_example', string
    end

    it 'converts from a symbol' do
      string = object.send(:underscore, :camelCaseExample)
      assert_equal 'camel_case_example', string
    end

    it 'converts the keys of a hash' do
      hash = {
        assetCategory: 'Asset Category',
        assetType: 'Asset Type'
      }

      new_hash = object.send(:underscore, hash)

      assert_equal new_hash['asset_category'], hash[:assetCategory]
      assert_equal new_hash['asset_type'], hash[:assetType]
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
      exception = assert_raises(NoMethodError) { object.underscore('test') }
      assert_includes exception.message, 'private method'
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

    it 'converts from a symbol' do
      string = object.send(:camelize, :this_is_a_test)
      assert_equal 'thisIsATest', string
    end

    it 'converts the keys of a hash' do
      hash = {
        asset_category: 'Asset Category',
        asset_type: 'Asset Type'
      }

      new_hash = object.send(:camelize, hash)

      assert_equal new_hash['assetCategory'], hash[:asset_category]
      assert_equal new_hash['assetType'], hash[:asset_type]
    end

    it 'is a private method' do
      exception = assert_raises(NoMethodError) { object.camelize('test') }
      assert_includes exception.message, 'private method'
    end
  end

  it "preserves the public nature of the including class's other methods" do
    assert_equal 'test', object.test
  end
end
