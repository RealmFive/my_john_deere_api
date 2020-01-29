require 'support/helper'

class EnvironmentHelperSample
  include JD::Helpers::EnvironmentHelper

  def initialize(environment = nil)
    self.environment = environment
  end
end

describe 'EnvironmentHelper' do
  let(:object) { EnvironmentHelperSample.new(environment) }
  let(:environment) { :sandbox }

  it 'provides an attr_reader for :environment' do
    assert object.environment
  end

  describe 'when no specific environment requested' do
    let(:environment) { nil }

    it 'sets the environment to :live' do
      assert_equal :live, object.environment
    end
  end

  describe 'when :sandbox environment requested' do
    let(:environment) { :sandbox }

    it 'sets the environment to :sandbox' do
      assert_equal environment, object.environment
    end
  end

  describe 'when :live environment requested' do
    let(:environment) { :live }

    it 'sets the environment to :live' do
      assert_equal environment, object.environment
    end
  end

  describe 'when :production synonym requested' do
    let(:environment) { :production }

    it 'sets the environment to :live' do
      assert_equal :live, object.environment
    end
  end

  describe 'when environment is passed as a string' do
    let(:environment) { 'sandbox' }

    it 'converts the environment to a symbol' do
      assert_equal :sandbox, object.environment
    end
  end

  describe 'when an unrecognized environment is requested' do
    let(:environment) { :turtles }

    it 'raises an error' do
      exception = assert_raises(JD::UnsupportedEnvironmentError) { object }
      assert_equal "The :turtles environment is not supported.", exception.message
    end
  end
end