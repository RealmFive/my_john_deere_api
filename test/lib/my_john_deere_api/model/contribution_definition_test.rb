require 'support/helper'

describe 'MyJohnDeereApi::Model::ContributionDefinition' do
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
    def link_for label
      camel_label = label.gsub(/_(.)/){|m| m[1].upcase}
      record['links'].detect{|link| link['rel'] == camel_label}['uri'].gsub('https://sandboxapi.deere.com/platform', '')
    end

    it 'sets the attributes from the given record' do
      definition = klass.new(record)

      # basic attributes
      assert_equal record['id'], definition.id
      assert_equal record['name'], definition.name
    end

    it 'links to other things' do
      product = klass.new(record)

      ['self', 'contribution_product'].each do |association|
        assert_equal link_for(association), product.links[association]
      end
    end

    it 'accepts an optional client' do
      asset = klass.new(record, client)
      assert_equal client, asset.client
    end
  end
end