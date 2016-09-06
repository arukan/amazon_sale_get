require 'base64'
require 'dotenv'
require 'json'
require 'net/http'
require 'openssl'
require 'rexml/document'
require 'time'
require 'uri'

ENDPOINT = 'webservices.amazon.co.jp'.freeze
REQUEST_URI = '/onca/xml'.freeze

Dotenv.load

require_relative './item_search'
require_relative './sales_info'

# TODO: upload json to aws s3
def upload_to_s3(json)
  p json
end

SalesInfo.sale_browse_nodes.each do |el|
  browse_node_id = el.elements['BrowseNodeId'].text

  puts 'sales node: ' \
       "#{el.elements['BrowseNodeId'].text} => #{el.elements['Name'].text}"

  1.upto(10) do |page_no|
    items = ItemSearch.items_per_page(browse_node_id, page_no)

    break if items.empty?

    # TODO: (TBD) In which file we get price by MWS API?
    # 1. get here and merge with items
    # 2. get ItemSearch.items_per_page

    upload_to_s3({ browse_node_id: browse_node_id,
                   page_no: page_no,
                   items: items }.to_json)
  end
end
