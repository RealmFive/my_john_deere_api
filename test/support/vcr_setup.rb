require 'vcr'

##########################################################################
# We're going to make a bunch of requests upfront so we can create/delete
# things in the correct order, and end up with no permanent changes to the
# sandbox environment. We only need to do this pre-emptively for resources
# where we create/delete. We build the client from scratch to get the full
# interaction history recorded.
##########################################################################

class VcrSetup
  attr_reader :api_key, :api_secret, :access_token, :access_secret, :verify_code,
              :contribution_product_id, :contribution_definition_id,
              :placeholders, :organization_id, :asset_id, :field_id, :flag_id

  GENERATED_CASSETTES = [
    :catalog, :get_request_token, :get_access_token,
    :get_contribution_products, :get_contribution_product,
    :get_organizations, :get_organization,
    :get_fields, :get_flags,
    :post_assets, :get_assets, :get_asset,
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
    @access_token = @uuid
    @access_secret = '0' * 107 + '='
    @contribution_product_id = @uuid
    @contribution_definition_id = @uuid
    @organization_id = '000000'
    @asset_id = @uuid
    @field_id = @uuid
    @flag_id = @uuid
    @verify_code = 'VERIFY'

    @placeholders = {
      API_KEY => @api_key,
      API_SECRET => @api_secret,
      ACCESS_TOKEN => @access_token,
      ACCESS_SECRET => @access_secret
    }

    unless all_cassettes_generated? || meets_vcr_requirements?
      raise "Cannot continue until VCR cassettes can be generated."
    end

    set_contribution_product_id
    set_contribution_definition_id
    set_organization_id

    configure_vcr

    url

    # create and retrieve things
    unless all_cassettes_generated?
      puts "\ngenerating:"

      GENERATED_CASSETTES.each do |method_name|
        filename = "#{method_name}.yml"

        if File.exist?("#{@vcr_dir}/#{filename}")
          puts " - using #{filename}"
        else
          puts " - generating #{filename}"
          VCR.use_cassette(method_name) { send(method_name) }
        end
      end
    end

    sanitize_files
  end

  # provide a client with sanitized credentials
  def client
    JD::Client.new(api_key, api_secret, environment: :sandbox, access: [access_token, access_secret])
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
      contribution_definition_id: ENV['CONTRIBUTION_DEFINITION_ID'],
      title: 'i like turtles',
      asset_category: 'DEVICE',
      asset_type: 'SENSOR',
      asset_sub_type: 'ENVIRONMENTAL',
      links: [
        {
          '@type' => 'Link',
          'rel' => 'contributionDefinition',
          'uri' => "#{url}/contributionDefinitions/#{ENV['CONTRIBUTION_DEFINITION_ID']}"
        }
      ]
    }.freeze
  end

  def asset_location_attributes
    @asset_location_attributes ||= {
      timestamp: timestamp,
      geometry: geometry,
      measurement_data: measurement_data
    }.freeze
  end

  private

  def all_cassettes_generated?
    return @all_cassettes_generated if defined?(@all_cassettes_generated)
    @all_cassettes_generated = GENERATED_CASSETTES.all?{|cassette| File.exist?("#{@vcr_dir}/#{cassette}.yml") }
  end

  # provide a fresh client with no memoized requests
  def new_client
    JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET])
  end

  def url
    return @url if defined?(@url)
    @url = VCR.use_cassette('url'){ new_client.send(:accessor).consumer.site }
  end

  def catalog
    new_client.get('/')
  end

  def get_request_token
    @temporary_authorize = JD::Authorize.new(API_KEY, API_SECRET, environment: :sandbox)
    @temporary_authorize_url = @temporary_authorize.authorize_url
  end

  def get_access_token
    puts "\n\n----\nFOLLOW THIS LINK, AND ENTER THE VERIFICATION CODE:\n#{@temporary_authorize_url}\n----\n\n"
    $stdout.print 'Verification Code: '; $stdout.flush
    code = $stdin.gets.chomp
    puts

    placeholders[code] = verify_code

    @temporary_authorize.verify(code)
  end

  def get_contribution_products
    new_client.get('/contributionProducts?clientControlled=true')
  end

  def get_organizations
    new_client.organizations.all
  end

  def get_organization
    new_client.get("/organizations/#{ENV['ORGANIZATION_ID']}")
  end

  def get_fields
    @temporary_field = find_organization(ENV['ORGANIZATION_ID']).fields.all.first
  end

  def get_flags
    @temporary_field.flags.all
  end

  def get_contribution_product
    new_client.get("/contributionProducts/#{ENV['CONTRIBUTION_PRODUCT_ID']}")
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
      data = File.read(filename)

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

      # various attributes
      # data.gsub!(/"name":".+?"/, '"name":"Name"')
      data.gsub!(/"marketPlaceName":".+?"/, '"marketPlaceName":"Marketplace Name"')
      data.gsub!(/"marketPlaceDescription":".+?"/, '"marketPlaceDescription":"Marketplace Description"')

      # oauth headers
      data.gsub!(/oauth_nonce="[0-9a-zA-Z]+"/, 'oauth_nonce="000000000000000000000000000000000000000000"')
      data.gsub!(/oauth_signature="[0-9a-zA-Z%]+"/, 'oauth_signature="0000000000000000000000000000"')
      data.gsub!(/oauth_token_secret=[0-9a-zA-Z%]+/, 'oauth_token_secret=000000000000000000000000000000000000000000')

      File.write(filename, data)
    end
  end

  def set_contribution_product_id
    unless ENV['CONTRIBUTION_PRODUCT_ID']
      set_env(
        'CONTRIBUTION_PRODUCT_ID',
        client.get('/contributionProducts?clientControlled=true')['values'].first['id']
      )
    end

    placeholders[ENV['CONTRIBUTION_PRODUCT_ID']] = contribution_product_id
  end

  def set_contribution_definition_id
    unless ENV['CONTRIBUTION_DEFINITION_ID']
      set_env(
        'CONTRIBUTION_DEFINITION_ID',
        client.get("/contributionProducts/#{ENV['CONTRIBUTION_PRODUCT_ID']}/contributionDefinitions")['values'].first['id']
      )
    end

    placeholders[ENV['CONTRIBUTION_DEFINITION_ID']] = contribution_definition_id
  end

  def set_organization_id
    unless ENV['ORGANIZATION_ID']
      set_env(
        'ORGANIZATION_ID',
        client.get("/organizations")['values'].first['id']
      )
    end

    placeholders[ENV['ORGANIZATION_ID']] = organization_id
  end

  def set_env(name, value)
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
    puts File.read("#{@vcr_dir}/warning.txt")
    $stdout.print("Do you meet the requirements? [y/N]: "); $stdout.flush

    answer = $stdin.gets.chomp
    answer.downcase == 'y'
  end
end