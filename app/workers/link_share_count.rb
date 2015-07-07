module BlueSkies
  module Workers
    class LinkShareCount
      include Sidekiq::Worker

      def perform(link_id)
        link = BlueSkies::Models::Link[link_id]
        return unless link
        link.update_share_count!
      end
    end
  end
end
