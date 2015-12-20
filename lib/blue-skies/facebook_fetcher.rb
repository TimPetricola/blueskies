module BlueSkies
  module FacebookFetcher
    UnexistingPageError = Class.new(StandardError)

    extend self

    WEEK = 60 * 60 * 24 * 7

    PAGE_PLACEHOLDER = 'PAGE'.freeze
    PAGE_ENDPOINT = "https://graph.facebook.com/v2.3/#{PAGE_PLACEHOLDER}/links".freeze

    def fetch(page, since = Time.now - WEEK)
      links = response(page, since)
      urls_from_raw_links(links['data'])
    end

    def response(page, since = nil)
      url = PAGE_ENDPOINT.gsub(PAGE_PLACEHOLDER, page)
      params = {
        fields: 'link',
        access_token: ENV['FACEBOOK_ACCESS_TOKEN'],
        limit: 100,
        since: since.to_i
      }
      Nestful.get(url, params).decoded
    rescue Nestful::ResourceNotFound => e
      raise UnexistingPageError.new("#{page} does not exist")
    end

    def urls_from_raw_links(raw)
      raw
        .map {|raw| url_from_raw_link(raw) }
        .compact
    end

    # Ensure
    def url_from_raw_link(raw)
      url = raw['link']
      return unless %r{^https?://}.match(url)
      return if /facebook\.com/.match(url)

      url_after_redirection(url)
    end

    # follow redirections and strip useless query parameters (utm_X)
    # Facebook is quite good at doing that
    def url_after_redirection(url)
      FacebookLink.info(url).url
    end
  end
end
