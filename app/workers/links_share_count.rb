module BlueSkies
  module Workers
    class LinksShareCount
      include Sidekiq::Worker
      include Sidetiq::Schedulable

      recurrence { daily }

      def perform
        BlueSkies::Models::Link.need_share_count_udpate.each do |link|
          LinkShareCount.perform_async(link.id)
        end
      end
    end
  end
end
