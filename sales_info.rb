# coding: utf-8

require_relative './base_request'

# This class get brose nodes which mean Amazon sale.
class SalesInfo < BaseRequest
  class << self
    def params
      DEFAULT_PARAMS.merge(
        Timestamp: Time.now.gmtime.iso8601,
        Operation: 'BrowseNodeLookup',
        BrowseNodeId: ENV['ROOT_BROWSE_NODE'],
        ResponseGroup: 'BrowseNodeInfo'
      )
    end

    def sale_browse_nodes
      content = get.body.gsub(/&(?!(?:amp|lt|gt|quot|apos);)/, '&amp;')
      doc = REXML::Document.new(content)
      doc.get_elements('//Children/*').select do |c|
        c.elements['Name'].text =~ /セール|off/i
      end
    end
  end
end
