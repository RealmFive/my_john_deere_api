require 'vcr'
require 'yaml'
require 'json'
require 'date'

##########################################################################
# We're going to make a bunch of requests upfront so we can create/delete
# things in the correct order, and end up with no permanent changes to the
# sandbox environment. We only need to do this pre-emptively for resources
# where we create/delete. We build the client from scratch to get the full
# interaction history recorded.
##########################################################################

class VcrSetup
  attr_reader :api_key, :api_secret, :access_token, :refresh_token,
              :verify_code, :contribution_product_id, :contribution_definition_id,
              :placeholders, :organization_id, :asset_id, :field_id, :flag_id

  AUTH_CASSETTES = [:catalog, :get_request_url, :get_access_token]

  GENERATED_CASSETTES = [
    :catalog, :get_request_url, :get_access_token,
    :get_contribution_products, :get_contribution_product,
    :get_contribution_definitions, :get_contribution_definition,
    :get_organizations, :get_organization,
    :get_fields, :get_field, :get_flags,
    :post_assets, :get_assets, :get_asset, :put_asset,
    :post_asset_locations, :get_asset_locations,
    :delete_asset
  ]

  def initialize
    @vcr_dir = File.dirname(__FILE__) + '/vcr'

    # Before we configure VCR, we want to make a few requests to set some constants
    @client = new_client

    # placeholders
    @uuid = '00000000-0000-0000-0000-000000000000'
    @api_key = 'johndeere-0000000000000000000000000000000000000000'
    @api_secret = '0' * 64
    @access_token = 'AccessToken0123456789abcdefghijklmnopqrstuvwxyz'
    @refresh_token = 'RefreshToken0123456789abcdefghijklmnopqrstuvwxyz'
    @contribution_product_id = @uuid
    @contribution_definition_id = @uuid
    @organization_id = '000000'
    @asset_id = @uuid
    @field_id = @uuid
    @flag_id = @uuid
    @verify_code = 'VERIFY'
    @placeholders = {}

    unless all_cassettes_generated? || meets_vcr_requirements?
      raise "Cannot continue until VCR cassettes can be generated."
    end

    configure_vcr

    # create and retrieve things
    unless all_cassettes_generated?
      puts "\ngenerating:"

      unless File.exist?(token_file)
        generate_cassettes(AUTH_CASSETTES)
      end

      @placeholders.merge!(
        ENV['API_KEY'] => @api_key,
        ENV['API_SECRET'] => @api_secret,
        current_access_token => @access_token,
        current_refresh_token => @refresh_token
      )

      VCR.use_cassette('temp') do
        set_contribution_product_id
        set_contribution_definition_id
        set_organization_id
      end

      File.unlink("#{@vcr_dir}/temp.yml") if File.exist?("#{@vcr_dir}/temp.yml")

      generate_cassettes(GENERATED_CASSETTES)
    end

    sanitize_files
  end

  # provide a client with sanitized credentials
  def client
    JD::Client.new(
      api_key,
      api_secret,
      contribution_definition_id: contribution_definition_id,
      environment: :sandbox,
      token_hash: token_hash,
      raise_errors: false,
    )
  end

  def timestamp
    return @timestamp if defined?(@timestamp)

    filename = "#{@vcr_dir}/get_asset_locations.yml"

    @timestamp = if File.exist?(filename)
      contents = File.read('test/support/vcr/get_asset_locations.yml')
      body = YAML.load(contents)['http_interactions'].last['response']['body']['string']
      JSON.parse(body)['values'].last['timestamp']
    else
      Time.now.strftime('%Y-%m-%dT%H:%M:%S.000Z')
    end
  end

  def epoch_timestamp
    return @epoch_timestamp if defined?(@epoch_timestamp)
    @epoch_timestamp = DateTime.parse(timestamp).to_time.to_i
  end

  def coordinates
    @coordinates ||= [-96.668978, 40.865984]
  end

  def geometry
    @geometry ||= {
      type: 'Feature',
      geometry: {
        geometries: [
          coordinates: coordinates,
          type: 'Point'
        ],
        type: 'GeometryCollection'
      }
    }
  end

  def measurement_data
    @measurement_data ||= [
      {
        name: 'Temperature',
        value: '68.0',
        unit: 'F'
      }
    ]
  end

  def asset_attributes
    @asset_attributes ||= {
      title: 'Asset Title',
      asset_category: 'DEVICE',
      asset_type: 'SENSOR',
      asset_sub_type: 'ENVIRONMENTAL'
    }.freeze
  end

  def asset_location_attributes
    @asset_location_attributes ||= {
      timestamp: timestamp,
      geometry: geometry,
      measurement_data: measurement_data
    }.freeze
  end

  def url
    return @url if defined?(@url)
    @url = JD::Consumer::URLS[:sandbox]
  end

  def token_hash
    return @token_hash if defined?(@token_hash)

    @token_hash = JSON.parse(File.read(token_file))

    token = OAuth2::AccessToken.from_hash(auth_client, @token_hash)

    if token.expired?
      new_token = token.refresh!
      set_token_hash(new_token)
    end

    @token_hash
  end

  private

  def generate_cassettes(list)
    list.each do |method_name|
      filename = "#{method_name}.yml"

      if File.exist?("#{@vcr_dir}/#{filename}")
        puts " - using #{filename}"
      else
        puts " - generating #{filename}"
        VCR.use_cassette(method_name) { send(method_name) }
      end
    end
  end

  def all_cassettes_generated?
    return @all_cassettes_generated if defined?(@all_cassettes_generated)
    @all_cassettes_generated = GENERATED_CASSETTES.all?{|cassette| File.exist?("#{@vcr_dir}/#{cassette}.yml") }
  end

  # provide a fresh client with no memoized requests
  def new_client
    JD::Client.new(
      ENV['API_KEY'],
      ENV['API_SECRET'],
      environment: :sandbox,
      contribution_definition_id: ENV['CONTRIBUTION_DEFINITION_ID'],
      token_hash: token_hash,
      raise_errors: false,
    )
  end

  def token_file
    './tmp/token_hash.json'
  end

  def current_access_token
    token_hash['access_token']
  end

  def current_refresh_token
    token_hash['refresh_token']
  end

  def set_token_hash(token)
    @token_hash = token.to_hash
    puts "TOKEN_HASH: #{@token_hash}"
    puts "PLACEHOLDERS: #{@placeholders}"
    File.write(token_file, @token_hash.to_json)
  end

  def auth_client
    OAuth2::Client.new(
      ENV['API_KEY'],
      ENV['API_SECRET'],
      site: 'https://sandboxapi.deere.com',
      authorize_url: 'https://signin.johndeere.com/oauth2/aus78tnlaysMraFhC1t7/v1/authorize',
      token_url: 'https://signin.johndeere.com/oauth2/aus78tnlaysMraFhC1t7/v1/token',
      raise_errors: false,
    )
  end

  def catalog
    new_client.get('/platform')
    new_client.get('https://signin.johndeere.com/oauth2/aus78tnlaysMraFhC1t7/.well-known/oauth-authorization-server')
  end

  def get_request_url
    @temporary_authorize = JD::Authorize.new(
      ENV['API_KEY'],
      ENV['API_SECRET'],
      environment: :sandbox,
      scopes: ['ag1', 'ag2', 'ag3'],
      redirect_uri: 'http://localhost'
    )

    @temporary_authorize_url = @temporary_authorize.authorize_url
  end

  def get_access_token
    get_request_url unless defined?(@temporary_authorize_url)

    puts "\n\n----\nFOLLOW THIS LINK, AND ENTER THE VERIFICATION CODE:\n#{@temporary_authorize_url}\n----\n\n"
    $stdout.print 'Verification Code: '; $stdout.flush
    code = $stdin.gets.chomp
    puts

    placeholders[code] = verify_code

    token = @temporary_authorize.verify(code)
    set_token_hash(token)
  end

  def get_contribution_products
    new_client.get('/contributionProducts?clientControlled=true')
  end

  def get_contribution_product
    new_client.get("/contributionProducts/#{ENV['CONTRIBUTION_PRODUCT_ID']}")
  end

  def get_contribution_definitions
    new_client.get("/contributionProducts/#{ENV['CONTRIBUTION_PRODUCT_ID']}/contributionDefinitions")
  end

  def get_contribution_definition
    new_client.get("/contributionDefinitions/#{ENV['CONTRIBUTION_DEFINITION_ID']}")
  end

  def get_organizations
    new_client.organizations.all
  end

  def get_organization
    new_client.organizations.find(ENV['ORGANIZATION_ID'])
  end

  def get_fields
    @temporary_field = find_organization(ENV['ORGANIZATION_ID']).fields.all.first
  end

  def get_field
    find_organization(ENV['ORGANIZATION_ID']).fields.find(@temporary_field.id)
  end

  def get_flags
    @temporary_field.flags.all
  end

  def post_assets
    @temporary_asset_id = find_organization(ENV['ORGANIZATION_ID']).assets.create(asset_attributes).id
    placeholders[@temporary_asset_id] = asset_id
  end

  def get_assets
    find_organization(ENV['ORGANIZATION_ID']).assets.all
  end

  def get_asset
    find_organization(ENV['ORGANIZATION_ID']).assets.find(@temporary_asset_id)
  end

  def put_asset
    attrs = asset_attributes.slice(
      :asset_category, :asset_type, :asset_sub_type, :links
    ).merge(
      title: 'i REALLY like turtles!',
      links: [
        {
          '@type' => 'Link',
          'rel' => 'contributionDefinition',
          'uri' => "#{url}/contributionDefinitions/#{asset_attributes[:contribution_definition_id]}"
        }
      ]
    )

    new_client.put("/assets/#{@temporary_asset_id}", attrs)
  end

  def delete_asset
    new_client.delete("/assets/#{@temporary_asset_id}")
  end

  def post_asset_locations
    find_asset(ENV['ORGANIZATION_ID'], @temporary_asset_id).locations.create(asset_location_attributes)
  end

  def get_asset_locations
    find_asset(ENV['ORGANIZATION_ID'], @temporary_asset_id).locations.all
  end

  def configure_vcr
    VCR.configure do |config|
      config.cassette_library_dir = 'test/support/vcr'
      config.hook_into :webmock
      config.default_cassette_options = {record: :once}
    end
  end

  def sanitize_files
    Dir[File.dirname(__FILE__) + "/vcr/**/*.yml"].each do |filename|
      text = sanitize_text(File.read(filename))

      data = YAML.load(text)
      sanitize_yaml!(data)

      File.write(filename, data.to_yaml)
    end
  end

  def sanitize_text(text)
    data = text

    placeholders.each do |value, placeholder|
      data.gsub!(value, placeholder)
    end

    # organization links
    data.gsub!(/\/organizations\/[0-9]+/, "/organizations/#{organization_id}")

    # random ids
    data.gsub!(/"id":"[0-9]+"/, '"id":"000000"')

    # uuids
    data.gsub!(/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/, @uuid)

    # timestamps
    data.gsub!(/[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}Z/, timestamp)
    data.gsub!(/1[4567][0-9]{8}/, epoch_timestamp.to_s)

    # geo coordinates
    data.gsub!(/\[-{0,1}[0-9]{1,3}\.[0-9]{6},-{0,1}[0-9]{1,3}\.[0-9]{6}\]/, coordinates.to_s.gsub(' ', ''))

    # oauth headers
    data.gsub!(/oauth_nonce="[0-9a-zA-Z]+"/, 'oauth_nonce="000000000000000000000000000000000000000000"')
    data.gsub!(/oauth_signature="[0-9a-zA-Z%]+"/, 'oauth_signature="0000000000000000000000000000"')
    data.gsub!(/oauth_token_secret=[0-9a-zA-Z%]+/, 'oauth_token_secret=000000000000000000000000000000000000000000')
    data.gsub!(/oauth_verifier="[0-9A-Za-z]{6}"/, 'oauth_verifier="VERIFY"')

    data
  end

  def sanitize_yaml!(data)
    if data.is_a?(Array)
      data.each { |item| sanitize_yaml!(item) }
    elsif data.is_a?(Hash)
      data.each do |key, value|
        if key == 'string'
          data[key] = sanitize_response_body(value)
        else
          sanitize_yaml!(value)
        end
      end
    end
  end

  def sanitize_response_body(string)
    data = nil

    # if this isn't JSON, just return the original string
    begin
      data = JSON.parse(string)
    rescue JSON::ParserError
      return string
    end

    # various response body attributes
    if data.is_a?(Hash)
      if data['values']
        data['values'].each do |value|
          value = sanitize_value(value)
        end
      elsif data['@type']
        data = sanitize_value(data)
      end
    elsif data.is_a?(Array)
      data.each do |value|
        # nothing yet
      end
    end

    data.to_json
  end

  def sanitize_value(value)
    merge_hash = case value['@type']
    when 'Organization'
      {'name' => 'Organization Name'}
    when 'ContributionProduct'
      {
        'marketPlaceName' => 'Market Place Name',
        'marketPlaceDescription' => 'Market Place Description'
      }
    when 'ContributionDefinition'
      {'name' => 'Definition Name'}
    when 'ContributedAsset'
      {
        'title' => 'Asset Title',
        'assetCategory' => 'DEVICE',
        'assetType' => 'SENSOR',
        'assetSubType' => 'ENVIRONMENTAL'
      }
    when 'Field'
      {'name' => 'Field Name'}
    else
      {}
    end

    value.merge!(merge_hash)
  end

  def set_contribution_product_id
    unless ENV['CONTRIBUTION_PRODUCT_ID']
      set_env(
        'CONTRIBUTION_PRODUCT_ID',
        new_client.get('/contributionProducts?clientControlled=true')['values'].first['id']
      )
    end

    placeholders[ENV['CONTRIBUTION_PRODUCT_ID']] = contribution_product_id
  end

  def set_contribution_definition_id
    unless ENV['CONTRIBUTION_DEFINITION_ID']
      set_env(
        'CONTRIBUTION_DEFINITION_ID',
        new_client.get("/contributionProducts/#{ENV['CONTRIBUTION_PRODUCT_ID']}/contributionDefinitions")['values'].first['id']
      )
    end

    placeholders[ENV['CONTRIBUTION_DEFINITION_ID']] = contribution_definition_id
  end

  def set_organization_id
    unless ENV['ORGANIZATION_ID']
      set_env(
        'ORGANIZATION_ID',
        new_client.get("/organizations")['values'].first['id']
      )
    end

    placeholders[ENV['ORGANIZATION_ID']] = organization_id
  end

  def set_env(name, value)
    puts "SAVING ENVIRONMENT VARIABLE: #{name}: #{value.inspect}"

    ENV[name] = value
    File.open('.env', 'a') { |f| f.puts "#{name}=#{value}"}
  end

  def find_organization(id)
    new_client.organizations.detect{|org| org.id == id}
  end

  def find_asset(org_id, id)
    find_organization(org_id).assets.detect{|asset| asset.id == id}
  end

  def meets_vcr_requirements?
    missing_env_vars = ['API_KEY', 'API_SECRET'].reject{|var| ENV[var]}

    unless missing_env_vars.empty?
      puts "The following required environment variables are missing: #{missing_env_vars.join(', ')}"
      return false
    end

    puts File.read("#{@vcr_dir}/warning.txt")
    $stdout.print("Do you meet the requirements? [y/N]: "); $stdout.flush

    answer = $stdin.gets.chomp
    answer.downcase == 'y'
  end
end