module BlueSkies
  module Workers
    class LinksExtract
      include Sidekiq::Worker
      include Sidetiq::Schedulable

      recurrence { hourly }

      def perform
        BlueSkies::Models::Link.unextracted.each do |link|
          LinkExtract.perform_async(link.id)
          LinkShareCount.perform_async(link.id)
        end
      end
    end
  end
end
