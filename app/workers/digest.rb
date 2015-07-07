module BlueSkies
  module Workers
    class Digest
      include Sidekiq::Worker

      sidekiq_options queue: :digest

      def perform(recipient_id, delivery_time = nil)
        recipient = BlueSkies::Models::Recipient[recipient_id]
        return unless recipient

        # Unersialize time
        delivery_time = Time.at(delivery_time).utc if delivery_time
        recipient.create_and_send_digest(delivery_time: delivery_time)
      end
    end
  end
end
