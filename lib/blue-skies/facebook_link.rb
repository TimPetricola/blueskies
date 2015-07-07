module BlueSkies
  module FacebookLink
    extend self

    LINK_PLACEHOLDER = 'LINK'.freeze
    LINK_ENDPOINT = "https://graph.facebook.com/v2.3/#{LINK_PLACEHOLDER}".freeze

    Data = Struct.new(:url, :share_count)

    def info(link)
      response = response(link)

      Data.new(
        url_from_response(response),
        shares_from_response(response)
      )
    end

    private

    def response(link)
      url = LINK_ENDPOINT.gsub(LINK_PLACEHOLDER, CGI.escape(link))
      params = {
        access_token: ENV['FACEBOOK_ACCESS_TOKEN'],
      }
      Nestful.get(url, params).decoded
    end

    def url_from_response(response)
      return unless response && response['og_object']
      response['og_object']['url']
    end

    def shares_from_response(response)
      return unless response['share']
      response['share']['share_count']
    end
  end
end
