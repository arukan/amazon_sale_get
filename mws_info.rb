# coding: utf-8

require_relative './base_mws_request'

# This class get brose nodes which mean Amazon sale.
class MWSLowestPriceInfo < BaseMWSRequest
  class << self
    def params
      DEFAULT_PARAMS.merge(
        Timestamp: Time.now.gmtime.iso8601,
        Action: 'GetLowestPricedOffersForASIN',
        ASIN: @asin_code,
        ItemCondition:  'new'
      )
    end

    def lowest_price_for_item(asin_code)
        p "lowest_price_for_item"
 @asin_code = asin_code
      p @asin_code
      #      p get.body
      p get

      content = get.body.gsub(/&(?!(?:amp|lt|gt|quot|apos);)/, '&amp;')
      .tap { |x| break REXML::Document.new(x) }
      .get_elements('//LowestPrices/LowestPrice/ListingPrice')
  
 
      p content
      
      
    end
  end
end
