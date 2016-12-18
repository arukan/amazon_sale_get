# This class has default behavior for aws request.
class BaseMWSRequest
  class << self
    DEFAULT_PARAMS = {
    #      Service: 'AWSMarketplaceWebService',
      Version: '2011-10-01',
      SignatureVersion: '2',
      SellerId: ENV['MWS_SELLER_ID'],
      SignatureMethod: 'HmacSHA256',
      MWSAuthToken: ENV['MWS_AUTH_TOKEN'],
      AWSAccessKeyId: ENV['AWS_ACCESS_KEY_ID'],
      MarketPlaceId: ENV['MWS_MARKET_PLACE_ID']
    }.freeze

    def canonical_query_string
        params.sort.collect do |key, value|
        [URI.escape(key.to_s,
                    Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")),
         URI.escape(value.to_s,
                    Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))].join('=')
      end.join('&')
    end

    def signed_url
      qs = canonical_query_string
      signature = Base64.encode64(
        OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'),
                             ENV['MWS_AWS_SECRET_ACCESS_KEY'],
                             "POST\n#{MWS_ENDPOINT}\n#{MWS_REQUEST_URI}\n#{qs}")
      ).strip


      format('https://%s%s?%s&Signature=%s',
             MWS_ENDPOINT, MWS_REQUEST_URI, qs,
             URI.escape(signature,
                        Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")))


    end

    def get
      uri = URI(signed_url)
      p uri
      #      netreturn = Net::HTTP.start(uri.host, uri.port) { |http| http.get(uri) }
      p uri.host
    p uri.port
    
      p "test1"
      
      #  res = Net::HTTP.post_form(URI.parse('http://54.238.183.170'),{'q' => 'ruby'})


      
      netreturn = Net::HTTP.start(uri.host, uri.port) { |http| http.post(uri,{"Action" => "GetLowestPricedOffersForASIN"}) }
            p "test"
            p netreturn
      netreturn
    end
  end
end
