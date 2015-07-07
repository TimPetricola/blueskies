module BlueSkies
  module Workers
    class CuratorFetch
      include Sidekiq::Worker

      def perform(curator_id)
        curator = BlueSkies::Models::Curator[curator_id]
        return unless curator
        curator.curate!
      end
    end
  end
end
