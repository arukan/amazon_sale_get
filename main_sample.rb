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
MWS_ENDPOINT = 'mws.amazonservices.jp'.freeze
MWS_REQUEST_URI = '/Products/2011-10-01'.freeze


Dotenv.load

require_relative './item_search'
require_relative './sales_info'
require_relative './mws_info'


# TODO: upload json to aws s3
def upload_to_s3(json)
  p json
end

MWSLowestPriceInfo.lowest_price_for_item("B01M4L4UZW")


