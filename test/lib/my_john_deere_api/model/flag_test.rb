require 'support/helper'
require 'json'

describe 'MyJohnDeereApi::Model::Flag' do
  include JD::LinkHelpers

  let(:klass) { JD::Model::Flag }

  let(:record) do
    {
      "@type"=>"Flag",
      "geometry"=>"{\"type\": \"Point\", \"coordinates\": [-93.14959274063109, 41.66881548411553] }",
      "archived"=>true,
      "proximityAlertEnabled"=>true,
      "notes"=>"Our flag is a very, very, very nice flag!",
      "id"=>"123456",
      "links"=>[
        {"@type"=>"Link", "rel"=>"field", "uri"=>"https://sandboxapi.deere.com/platform/organizations/#{organization_id}/fields/#{field_id}"},
        {"@type"=>"Link", "rel"=>"createdBy", "uri"=>"https://sandboxapi.deere.com/platform/users/bobsmith"},
        {"@type"=>"Link", "rel"=>"lastModifiedBy", "uri"=>"https://sandboxapi.deere.com/platform/users/jonsmith"},
      ]
    }
  end

  describe '#initialize' do
    it 'sets the attributes from the given record' do
      flag = klass.new(client, record)

      assert_equal client, flag.client
      assert_equal accessor, flag.accessor

      # basic attributes
      assert_equal JSON.parse(record['geometry']), flag.geometry
      assert_equal record['archived'], flag.archived?
      assert_equal record['proximityAlertEnabled'], flag.proximity_alert_enabled?
      assert_equal record['notes'], flag.notes
      assert_equal record['id'], flag.id

      # links to other things
      assert_kind_of Hash, flag.links

      [:field, :created_by, :last_modified_by].each do |attribute|
        assert_link_for(flag, attribute)
      end
    end
  end
end