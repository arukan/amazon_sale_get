#!/usr/bin/env ruby

require 'time'
require 'uri'
require 'openssl'
require 'base64'

=begin
# Your AWS Access Key ID, as taken from the AWS Your Account page
AWS_ACCESS_KEY_ID = "AKIAJ5INMXIBT3ZRZHIA"

# Your AWS Secret Key corresponding to the above ID, as taken from the AWS Your Account page
AWS_SECRET_KEY = "cD7GVBnNO90fHDwxqja4cSM/WTrfHPcKdgxWh8TA"

# The region you are interested in
ENDPOINT = "webservices.amazon.co.jp"

REQUEST_URI = "/onca/xml"

=end

def itemSearch(browseNodeId,pageNumber)

params = {
    "Service" => "AWSECommerceService",
    "Operation" => "ItemSearch",
    "AWSAccessKeyId" => "XXXXXXXX",
    "AssociateTag" => "XXX-XXX-XXX",
    "SearchIndex" => "Books",
    "ResponseGroup" => "Images,ItemAttributes,Offers,SalesRank",
    "Sort" => "salesrank",
    "BrowseNode" => browseNodeId,
    "ItemPage" => pageNumber
    
}

# Set current timestamp if not set
params["Timestamp"] = Time.now.gmtime.iso8601 if !params.key?("Timestamp")

# Generate the canonical query
canonical_query_string = params.sort.collect do |key, value|
    [URI.escape(key.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")), URI.escape(value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))].join('=')
end.join('&')

# Generate the string to be signed
string_to_sign = "GET\n#{ENDPOINT}\n#{REQUEST_URI}\n#{canonical_query_string}"

# Generate the signature required by the Product Advertising API
signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), AWS_SECRET_KEY, string_to_sign)).strip()

# Generate the signed URL
"http://#{ENDPOINT}#{REQUEST_URI}?#{canonical_query_string}&Signature=#{URI.escape(signature, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"

end