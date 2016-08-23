# This class has default behavior for aws request.
class BaseRequest
  class << self
    DEFAULT_PARAMS = {
      Service: 'AWSECommerceService',
      AWSAccessKeyId: ENV['AWS_ACCESS_KEY_ID'],
      AssociateTag: ENV['ASSOCIATE_TAG']
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
                             ENV['AWS_SECRET_KEY'],
                             "GET\n#{ENDPOINT}\n#{REQUEST_URI}\n#{qs}")
      ).strip

      format('http://%s%s?%s&Signature=%s',
             ENDPOINT, REQUEST_URI, qs,
             URI.escape(signature,
                        Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")))
    end

    def get
      uri = URI(signed_url)
      Net::HTTP.start(uri.host, uri.port) { |http| http.get(uri) }
    end
  end
end
