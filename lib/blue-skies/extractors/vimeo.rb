module BlueSkies
  module Extractors
    module Vimeo
      extend self

      VIMEO_REGEX = %r{
        (https?://)?
        (www.)?
        (player.)?
        vimeo.com/
        ([a-z]*/)*(?<id>[0-9]{6,11})[?]?.*
      }x

      API_VIDEO_PLACEHOLDER = 'VIDEO_ID'.freeze
      API_ENDPOINT = "https://vimeo.com/api/v2/video/#{API_VIDEO_PLACEHOLDER}.json".freeze

      def extract(source, data)
        response = response(source.url)
        return data unless response
        data.keywords = keywords_from_response(response)
        data
      end

      private

      def video_id(url)
        match = VIMEO_REGEX.match(url)
        match && match[:id].to_i
      end

      def response(url)
        video_id = video_id(url)
        return unless video_id

        api_endpoint = API_ENDPOINT.gsub(API_VIDEO_PLACEHOLDER, video_id.to_s)
        Nestful.get(api_endpoint).decoded.first
      rescue Nestful::ResourceNotFound
        nil
      end

      def keywords_from_response(response)
        tags = response['tags']
        return Set.new if tags.nil? || tags.empty?

        tags.to_s.split(', ').to_set
      end
    end
  end
end
