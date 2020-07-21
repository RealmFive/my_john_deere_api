require 'support/helper'

describe 'MyJohnDeereApi::Client' do
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

    it 'accepts access token/secret' do
      access_token = 'token'
      access_secret = 'secret'

      client = JD::Client.new(api_key, api_secret, access: [access_token, access_secret])

      assert_equal access_token, client.access_token
      assert_equal access_secret, client.access_secret
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
      custom_retries = NetHttpRetry::Decorator::DEFAULTS[:max_retries] + 10

      VCR.use_cassette('catalog') do
        new_client = JD::Client.new(
          api_key,
          api_secret,
          contribution_definition_id: contribution_definition_id,
          environment: :sandbox,
          access: [access_token, access_secret],
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
      response = VCR.use_cassette('get_organizations') { client.get('/organizations') }

      assert_kind_of Hash, response
      assert_kind_of Integer, response['total']
      assert response['values'].all?{|value| value['@type'] == 'Organization'}
      assert response['values'].all?{|value| value.has_key?('links')}
    end

    it 'prepends the leading slash if needed' do
      response = VCR.use_cassette('get_organizations') { client.get('organizations') }

      assert_kind_of Hash, response
      assert_kind_of Integer, response['total']
      assert response['values'].all?{|value| value['@type'] == 'Organization'}
      assert response['values'].all?{|value| value.has_key?('links')}
    end

    it 'allows symbols for simple resources' do
      response = VCR.use_cassette('get_organizations') { client.get(:organizations) }

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
        client.post("/organizations/#{organization_id}/assets", attributes)
      end

      assert_equal '201', response.code
      assert_equal 'Created', response.message
      assert_equal "#{base_url}/assets/#{asset_id}", response['Location']
    end

    it 'prepends the leading slash if needed' do
      response = VCR.use_cassette('post_assets') do
        client.post("organizations/#{organization_id}/assets", attributes)
      end

      assert_equal '201', response.code
      assert_equal 'Created', response.message
      assert_equal "#{base_url}/assets/#{asset_id}", response['Location']
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
      response = VCR.use_cassette('put_asset') { client.put("/assets/#{asset_id}", attributes) }

      assert_equal '204', response.code
      assert_equal 'No Content', response.message
    end

    it 'prepends the leading slash if needed' do
      response = VCR.use_cassette('put_asset') { client.put("assets/#{asset_id}", attributes) }

      assert_equal '204', response.code
      assert_equal 'No Content', response.message
    end
  end

  describe '#delete' do
    it 'sends the request' do
      response = VCR.use_cassette('delete_asset') { client.delete("/assets/#{asset_id}") }

      assert_equal '204', response.code
      assert_equal 'No Content', response.message
    end

    it 'prepends the leading slash if needed' do
      response = VCR.use_cassette('delete_asset') { client.delete("assets/#{asset_id}") }

      assert_equal '204', response.code
      assert_equal 'No Content', response.message
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

  describe '#consumer' do
    it 'receives the api key/secret and environment of the client' do
      environment = :sandbox

      client = JD::Client.new(api_key, api_secret, environment: environment)
      consumer = client.send :consumer

      assert_kind_of JD::Consumer, consumer
      assert_equal api_key, consumer.api_key
      assert_equal api_secret, consumer.api_secret
      assert_equal environment, consumer.environment
    end
  end

  describe '#accessor' do
    it 'returns an object that can make user-specific requests' do
      assert_kind_of NetHttpRetry::Decorator, accessor
      assert_kind_of OAuth::Consumer, accessor.consumer
      assert_equal access_token, accessor.token
      assert_equal access_secret, accessor.secret
    end
  end
end