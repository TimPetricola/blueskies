module BlueSkies
  module Workers
    class Curate
      include Sidekiq::Worker
      include Sidetiq::Schedulable

      recurrence { hourly }

      def perform
        BlueSkies::Models::Curator.all.each do |curator|
          CuratorFetch.perform_async(curator.id)
        end
      end
    end
  end
end
