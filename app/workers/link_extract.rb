module BlueSkies
  module Workers
    class LinkExtract
      include Sidekiq::Worker

      def perform(link_id)
        link = BlueSkies::Models::Link[link_id]
        return unless link
        link.extract!
      end
    end
  end
end
