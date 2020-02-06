require 'support/helper'

describe 'MyJohnDeereApi::Model::ContributionProduct' do
  let(:record) do
    {
      "@type" => "ContributionProduct",
      "marketPlaceName" => "SpiffyApp",
      "marketPlaceDescription" => "SpiffyApp",
      "marketPlaceLogo" => "https://example.com/logo.png",
      "defaultLocale" => "en-us",
      "currentStatus" => "APPROVED",
      "activationCallback" => "https://example.com/activation_callback",
      "previewImages" => ["https://example.com/preview.png"],
      "supportedRegions" => ["US"],
      "supportedOperationCenters" => ["something"],
      "id" => "#{contribution_product_id}",
      "links" => [
        {
          "@type" => "Link",
          "rel" => "self",
          "uri" => "https://sandboxapi.deere.com/platform/contributionProducts/#{contribution_product_id}"
        },
        {
          "@type" => "Link",
          "rel" => "contributionDefinition",
          "uri" => "https://sandboxapi.deere.com/platform/contributionProducts/#{contribution_product_id}/contributionDefinitions"
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
      product = JD::Model::ContributionProduct.new(record)

      # basic attributes
      assert_equal record['id'], product.id
      assert_equal record['marketPlaceName'], product.market_place_name
      assert_equal record['marketPlaceDescription'], product.market_place_description
      assert_equal record['defaultLocale'], product.default_locale
      assert_equal record['currentStatus'], product.current_status
      assert_equal record['activationCallback'], product.activation_callback
      assert_equal record['previewImages'], product.preview_images
      assert_equal record['supportedRegions'], product.supported_regions
      assert_equal record['supportedOperationCenters'], product.supported_operation_centers
    end

    it 'links to other things' do
      product = JD::Model::ContributionProduct.new(record)

      ['self', 'contribution_definition'].each do |association|
        assert_equal link_for(association), product.links[association]
      end
    end

    it 'accepts an optional accessor' do
      mock_accessor = 'mock-accessor'

      asset = JD::Model::ContributionProduct.new(record, mock_accessor)
      assert_equal mock_accessor, asset.accessor
    end
  end
end