require 'ostruct'

module BlueSkies
  module Extractor
    DEFAULT_EXTRACTORS = [Extractors::Embedly, Extractors::Vimeo]

    class Source
      attr_reader :url

      def initialize(url)
        @url = url
      end
    end

    def self.extract(url)
      source = Source.new(url)
      DEFAULT_EXTRACTORS.reduce(OpenStruct.new) do |data, extractor|
        extractor.extract(source, data)
      end
    end
  end
end
