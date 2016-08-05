#!/usr/bin/env ruby
# coding: utf-8

require 'time'
require 'uri'
require 'openssl'
require 'base64'
require 'net/http'
require 'rexml/document'
require './item_search'
require 'pry-byebug'
require 'dotenv'

Dotenv.load

ENDPOINT = 'webservices.amazon.co.jp'
REQUEST_URI = '/onca/xml'

params = {
  'Service' => 'AWSECommerceService',
  'Operation' => 'BrowseNodeLookup',
  'AWSAccessKeyId' => ENV['AWS_ACCESS_KEY_ID'],
  'AssociateTag' => ENV['ASSOCIATE_TAG'],
  'BrowseNodeId' => ENV['ROOT_BROWSE_NODE'],
  'ResponseGroup' => 'BrowseNodeInfo'
}

# Set current timestamp if not set
params['Timestamp'] = Time.now.gmtime.iso8601 if !params.key?('Timestamp')

# Generate the canonical query
canonical_query_string = params.sort.collect do |key, value|
  [URI.escape(key.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")), URI.escape(value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))].join('=')
end.join('&')

# Generate the string to be signed
string_to_sign = "GET\n#{ENDPOINT}\n#{REQUEST_URI}\n#{canonical_query_string}"

# Generate the signature required by the Product Advertising API
signature = Base64.encode64(
  OpenSSL::HMAC.digest(
    OpenSSL::Digest.new('sha256'),
    ENV['AWS_SECRET_KEY'], string_to_sign
  )
).strip()

# Generate the signed URL
request_url = "http://#{ENDPOINT}#{REQUEST_URI}?#{canonical_query_string}&Signature=#{URI.escape(signature, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"

uri= URI(request_url)
res = Net::HTTP.start(uri.host, uri.port) do |http|
  http.get(uri)
end

content = res.body.gsub(/&(?!(?:amp|lt|gt|quot|apos);)/, '&amp;')
doc = REXML::Document.new(content)

doc.get_elements('//Children/*').each do |child|
  browse_node_id = child.elements['BrowseNodeId'].text

  name = child.elements['Name'].text
  if name =~ /セール|off/i
    puts "#{browse_node_id} #{name}"
    
    1.upto(10) do |page_no|

      uri= URI(itemSearch(browse_node_id, page_no))
      res = Net::HTTP.start(uri.host, uri.port) do |http|
        http.get(uri)
      end

      items_xml = res.body.gsub(/&(?!(?:amp|lt|gt|quot|apos);)/, '&amp;')
                  .tap { |x| break REXML::Document.new(x) }
                  .get_elements('//Items/Item')

      items_xml.each do | xml |

        attrs =xml.elements['ItemAttributes']
        product_group = attrs.elements['ProductGroup'].text

        if product_group == 'eBooks'
          asin = xml.elements['ASIN'].text
          #     binding.pry
          author = attrs.elements['Author'].text
          node_format = attrs.elements['Format'].text
          is_adult_product = attrs.elements['IsAdultProduct'].text
          puts    label = attrs.elements['Label'].text
          manufacturer = attrs.elements['Manufacturer'].text
          product_typename = attrs.elements['ProductTypeName'].text
          publication_date = attrs.elements['ReleaseDate'].text
          #       binding.pry
          if xml.elements['SalesRank']
            sales_rank = xml.elements['SalesRank'].text
          end
        end

        # author = xml.elements['Author'].text
        #         asin = xml.elements['ASIN'].text
        #         asin = xml.elements['ASIN'].text
        #         asin = xml.elements['ASIN'].text
        #         asin = xml.elements['ASIN'].text
        #         asin = xml.elements['ASIN'].text
      end
    end
  end

=begin
  process_items(
    ::Api::ItemSearch.new.execute(
      SearchIndex: search_index_name,
      BrowseNode: browse_node_id,
      ResponseGroup: 'Images,ItemAttributes,OfferFull,SalesRank',
      Sort: 'salesrank',
      ItemPage: page_no
    )
  )
=end

end
