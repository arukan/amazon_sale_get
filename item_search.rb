require_relative './base_request'

# This class get items from Amazon.
class ItemSearch < BaseRequest
  PICKUP = 'eBooks'.freeze
  XML_ATTRS = [:ASIN,
               {
                 ItemAttributes: [
                   :Author, :Format, :Title,
                   :Binding, :Format, :IsAdultProduct,
                   :Label, :Manifacturer, :ProductGroup,
                   :ProductTypeName, :PublicationDate, :SalesRank
                 ]
               }].freeze

  class << self
    @browse_node_id = nil
    @page_no = nil

    def params
      DEFAULT_PARAMS.merge(
        BrowseNode: @browse_node_id,
        ItemPage: @page_no,
        Operation: 'ItemSearch',
        SearchIndex: 'Books',
        ResponseGroup: 'Images,ItemAttributes,Offers,SalesRank',
        Sort: 'salesrank'
      )
    end

    # @param [Array] x xpath basenames (e.g. `[:Author, :Format, ...]`)
    # @param [String] key prefix of xpath (e.g. `ItemAttributes/`)
    # @return [Array] xpaths (e.g. `['ItemAttributes/Author', ...]`)
    def to_xpaths(x, key = nil)
      a = []
      x.each do |el|
        a +=
          case el
          when Hash then to_xpaths(el.values, "#{key}#{el.keys.first}/")
          when Array then to_xpaths(el, key)
          else; ["#{key}#{el}"]
          end
      end
      a
    end

    # @param [String] browse_node_id id of browsenode
    # @param [Integer] page_no page no to be specified in ItemSerach request
    # @return [Hash] includes item array
    def items_per_page(browse_node_id, page_no)
      @browse_node_id = browse_node_id
      @page_no = page_no

      items_xml = get.body.gsub(/&(?!(?:amp|lt|gt|quot|apos);)/, '&amp;')
                     .tap { |x| break REXML::Document.new(x) }
                     .get_elements('//Items/Item')

      items = []
      attrs_xpaths = to_xpaths(XML_ATTRS)

      items_xml.each do |xml|
        next unless xml.elements['ItemAttributes/ProductGroup'].text == PICKUP
        item = {}

        attrs_xpaths.each do |attr_xpath|
          el = xml.elements[attr_xpath]
          item[File.basename(attr_xpath).downcase] = el ? el.text : ''
        end

        items << item
      end

      items
    end
  end
end
