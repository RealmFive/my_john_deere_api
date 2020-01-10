require 'support/helper'
require 'json'

describe 'MyJohnDeereApi::Model::AssetLocation' do
  let(:record) do
    {
      "@type"=>"ContributedAssetLocation",
      "timestamp"=>"2017-09-20T21:30:59.000Z",
      "geometry"=>"{\"type\": \"Feature\",\"geometry\": {\"geometries\": [{\"coordinates\": [ -103.115633, 41.670166],\"type\": \"Point\"}],\"type\": \"GeometryCollection\"}}",
      "measurementData"=>[
        {
          "@type"=>"BasicMeasurement",
          "name"=>"[1 Foot](https://app.realmfive.com/map?device=0x0080CDEF)",
          "value"=>"82",
          "unit"=>"cB"
        }, {
          "@type"=>"BasicMeasurement",
          "name"=>"[2 Feet](https://app.realmfive.com/map?device=0x0080CDEF)",
          "value"=>"31",
          "unit"=>"cB"
        }
      ],
      "links"=>[]
    }
  end

  let(:client) { JD::Client.new(API_KEY, API_SECRET, environment: :sandbox, access: [ACCESS_TOKEN, ACCESS_SECRET]) }
  let(:accessor) { VCR.use_cassette('catalog') { client.send(:accessor) } }

  describe '#initialize' do
    def link_for label
      record['links'].detect{|link| link['rel'] == label}['uri'].gsub('https://sandboxapi.deere.com/platform', '')
    end

    it 'sets the attributes from the given record' do
      location = JD::Model::AssetLocation.new(record)

      assert_nil location.accessor

      # basic attributes
      assert_equal record['timestamp'], location.timestamp
      assert_equal JSON.parse(record['geometry']), location.geometry
      assert_equal record['measurementData'], location.measurement_data

      # links to other things
      assert_kind_of Hash, location.links
      assert_equal 0, location.links.size
    end

    it 'accepts an optional accessor' do
      accessor = 'mock-accessor'

      location = JD::Model::AssetLocation.new(record, accessor)
      assert_equal accessor, location.accessor
    end
  end
end