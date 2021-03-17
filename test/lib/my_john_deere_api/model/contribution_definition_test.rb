require 'support/helper'

describe 'MyJohnDeereApi::Model::ContributionDefinition' do
  include JD::LinkHelpers

  let(:klass) { JD::Model::ContributionDefinition }

  let(:record) do
    {
      "@type" => "ContributionDefinition",
      "name" => "Definition Name",
      "actionDefinitions" => [],
      "id" => "00000000-0000-0000-0000-000000000000",
      "links" => [
        {
          "@type" => "Link",
          "rel" => "self",
          "uri" => "https://sandboxapi.deere.com/platform/contributionDefinitions/00000000-0000-0000-0000-000000000000"
        },
        {
          "@type" => "Link",
          "rel" => "contributionProduct",
          "uri" => "https://sandboxapi.deere.com/platform/contributionProducts/00000000-0000-0000-0000-000000000000"
        }
      ]
    }
  end

  describe '#initialize' do
    it 'sets the attributes from the given record' do
      definition = klass.new(client, record)

      assert_equal client, definition.client

      # basic attributes
      assert_equal record['id'], definition.id
      assert_equal record['name'], definition.name
    end

    it 'links to other things' do
      product = klass.new(client, record)

      ['self', 'contribution_product'].each do |association|
        assert_link_for product, association
      end
    end
  end
end