module BlueSkies
  module Models
    class Image < Struct.new(:url, :width, :height, :color)
      def width
        super.to_i
      end

      def height
        super.to_i
      end

      def resized(width:, height:)
        self.class.new(
          resized_url(width: width, height: height),
          width,
          height,
          color
        )
      end

      def ratio
        width.to_f / height.to_f
      end

      def bigger?(ratio: nil, width: nil, height: nil)
        (
          (!ratio || self.ratio > ratio) &&
          (!width || self.width > width) &&
          (!height || self.height > height)
        )
      end

      def showable?
        bigger?(ratio: 1, width: 666, height: 400)
      end

      private

      def resized_url(width:, height:)
        params = {
          width: width,
          height: height,
          url: CGI.escape(url),
          key: ENV['EMBEDLY_KEY']
        }

        params_string = params.map { |k, v| "#{k}=#{v}" }.join('&')

        "http://i.embed.ly/1/display/crop?#{params_string}"
      end
    end
  end
end
