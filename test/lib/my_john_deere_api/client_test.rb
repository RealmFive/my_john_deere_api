require 'support/helper'

describe 'MyJohnDeereApi::Client' do
  include JD::ResponseHelpers

  it 'includes the CaseConversion helper' do
    client = JD::Client.new(api_key, api_secret)
    assert_equal 'thisIsATest', client.send(:camelize, :this_is_a_test)
  end

  describe '#initialize(api_key, api_secret, options={})' do
    it 'sets the api key/secret' do
      client = JD::Client.new(api_key, api_secret)

      assert_equal api_key, client.api_key
      assert_equal api_secret, client.api_secret
    end

    it 'accepts token_hash' do
      client = JD::Client.new(api_key, api_secret, token_hash: token_hash)

      assert_equal token_hash, client.token_hash
    end

    it 'accepts the environment' do
      environment = :sandbox

      client = JD::Client.new(api_key, api_secret, environment: environment)
      assert_equal environment, client.environment
    end

    it 'accepts a contribution_definition_id' do
      client = JD::Client.new(api_key, api_secret, contribution_definition_id: contribution_definition_id)
      assert_equal contribution_definition_id, client.contribution_definition_id
    end

    it 'accepts a list of parameters for NetHttpRetry' do
      custom_retries = JD::NetHttpRetry::Decorator::DEFAULTS[:max_retries] + 10

      VCR.use_cassette('catalog') do
        new_client = JD::Client.new(
          api_key,
          api_secret,
          contribution_definition_id: contribution_definition_id,
          environment: :sandbox,
          token_hash: token_hash,
          http_retry: {max_retries: custom_retries}
        )

        assert_equal custom_retries, new_client.accessor.max_retries
      end
    end
  end

  describe '#contribution_definition_id' do
    it 'can be set after instantiation' do
      client = JD::Client.new(api_key, api_secret)
      assert_nil client.contribution_definition_id

      client.contribution_definition_id = '123'
      assert_equal '123', client.contribution_definition_id
    end
  end

  describe '#get' do
    it 'returns the response as a Hash' do
      response = VCR.use_cassette('get_organizations') { client.get('/platform/organizations') }

      assert_kind_of Hash, response
      assert_kind_of Integer, response['total']
      assert response['values'].all?{|value| value['@type'] == 'Organization'}
      assert response['values'].all?{|value| value.has_key?('links')}
    end

    it 'prepends the leading slash if needed' do
      response = VCR.use_cassette('get_organizations') { client.get('platform/organizations') }

      assert_kind_of Hash, response
      assert_kind_of Integer, response['total']
      assert response['values'].all?{|value| value['@type'] == 'Organization'}
      assert response['values'].all?{|value| value.has_key?('links')}
    end
  end

  describe '#post' do
    let(:attributes) do
      CONFIG.asset_attributes.merge(
        links: [
          {
            '@type' => 'Link',
            'rel' => 'contributionDefinition',
            'uri' => "#{CONFIG.url}/contributionDefinitions/#{contribution_definition_id}"
          }
        ]
      )
    end

    it 'returns the response as a Hash' do
      response = VCR.use_cassette('post_assets') do
        client.post("/platform/organizations/#{organization_id}/assets", attributes)
      end

      assert_created response
      assert_equal "#{base_url}/platform/assets/#{asset_id}", response.response.headers['Location']
    end

    it 'prepends the leading slash if needed' do
      response = VCR.use_cassette('post_assets') do
        client.post("platform/organizations/#{organization_id}/assets", attributes)
      end

      assert_created response
      assert_equal "#{base_url}/platform/assets/#{asset_id}", response.response.headers['Location']
    end
  end

  describe '#put' do
    let(:new_title) { 'i REALLY like turtles!' }

    let(:attributes) do
      CONFIG.asset_attributes.slice(
        :asset_category, :asset_type, :asset_sub_type, :links
      ).merge(
        title: new_title,
        links: [
          {
            '@type' => 'Link',
            'rel' => 'contributionDefinition',
            'uri' => "#{CONFIG.url}/contributionDefinitions/#{contribution_definition_id}"
          }
        ]
      )
    end

    it 'sends the request' do
      response = VCR.use_cassette('put_asset') { client.put("/platform/assets/#{asset_id}", attributes) }

      assert_no_content response
    end

    it 'prepends the leading slash if needed' do
      response = VCR.use_cassette('put_asset') { client.put("platform/assets/#{asset_id}", attributes) }

      assert_no_content response
    end
  end

  describe '#delete' do
    it 'sends the request' do
      response = VCR.use_cassette('delete_asset') { client.delete("/platform/assets/#{asset_id}") }

      assert_no_content response
    end

    it 'prepends the leading slash if needed' do
      response = VCR.use_cassette('delete_asset') { client.delete("platform/assets/#{asset_id}") }

      assert_no_content response
    end
  end

  describe '#organizations' do
    it 'returns a collection of organizations for this account' do
      organizations = VCR.use_cassette('get_organizations') { client.organizations.all; client.organizations }

      assert_kind_of JD::Request::Collection::Organizations, organizations

      organizations.each do |organization|
        assert_kind_of JD::Model::Organization, organization
      end
    end
  end

  describe '#contribution_products' do
    it 'returns a collection of contribution products for this account' do
      contribution_products = VCR.use_cassette('get_contribution_products') { client.contribution_products.all; client.contribution_products }

      assert_kind_of JD::Request::Collection::ContributionProducts, contribution_products

      contribution_products.each do |contribution_product|
        assert_kind_of JD::Model::ContributionProduct, contribution_product
      end
    end
  end

  describe '#accessor' do
    it 'returns an object that can make user-specific requests' do
      assert_kind_of JD::NetHttpRetry::Decorator, accessor
    end
  end
end