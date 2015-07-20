module BlueSkies
  module Workers
    class NewRecipientNotify
      include Sidekiq::Worker

      def perform(recipient_id)
        recipient = BlueSkies::Models::Recipient[recipient_id]
        return unless recipient

        Nestful::Request.new(
          "https://api.mailgun.net/v3/#{ENV['MAILGUN_DOMAIN']}/messages",
          method: :post,
          auth_type: :basic,
          user: 'api',
          password: ENV['MAILGUN_KEY'],
          params: {
            to: ENV['SEND_FROM'],
            from: ENV['SEND_FROM'],
            subject: '[Blue Skies] New recipient',
            text: [
              "- Email: #{recipient.email}",
              "- Schedule: #{recipient.schedule}",
              "- Interests: #{recipient.interests.map(&:name).join(', ')}",
              "#{Models::Recipient.count} recipients in total."
            ].join("\n")
          }
        ).execute
      end
    end
  end
end
