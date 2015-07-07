module BlueSkies
  module Extractors
    module Embedly
      extend self

      API_ENDPOINT = 'https://api.embed.ly/1/extract'.freeze
      IMAGE_STRUCT = Struct.new(:url, :width, :height, :color)

      def extract(source, data)
        response = response(source.url)
        data.title = response['title']
        data.description = response['description']
        data.images = images_from_response(response)
        data.keywords = keywords_from_response(response)
        data
      end

      private

      def response(url)
        Nestful.get(API_ENDPOINT, url: url, key: ENV['EMBEDLY_KEY']).decoded
      rescue Nestful::ResourceNotFound
        {}
      end

      def images_from_response(response)
        images = response['images']
        return [] if images.nil? || images.empty?

        images.map do |raw_image|
          IMAGE_STRUCT.new(
            raw_image['url'],
            raw_image['width'],
            raw_image['height'],
            color_from_image(raw_image)
          )
        end
      end

      def color_from_image(raw_image)
        candidates = raw_image['colors']
        return if candidates.nil? || candidates.empty?

        candidates = candidates.sort_by { |candidate| candidate['weight'] }
        rgb = candidates.last['color']
        '#' + rgb_to_hex(rgb)
      end

      def rgb_to_hex(rgb)
        rgb.map { |c| c.to_s(16).rjust(2, '0') }.join
      end

      def keywords_from_response(response)
        raw_keywords = response['keywords']
        return Set.new if raw_keywords.nil? || raw_keywords.empty?

        raw_keywords.map { |raw_keyword| raw_keyword['name'] }.to_set
      end
    end
  end
end
