module BlueSkies
  module Routes
    class Home < Base
      get '/' do
        erb :form, locals: form_locals(form: Forms::Recipient.new(params))
      end

      post '/subscriptions' do
        form = Forms::Recipient.new(params)

        return erb(:form, locals: form_locals(form: form)) unless form.valid?

        if Models::Recipient.exists?(email: form.email)
          return erb :already_subscribed
        end

        recipient = Models::Recipient.create(email: form.email)
        now = Time.now

        recipient.update_schedule(
          week_days: form.biweekly? ? [:wednesday, :sunday] : [:sunday],
          time: Time.new(now.year, now.month, now.day, 9, 0, 0, form.timezone * 3600).utc
        )

        form.interests_ids.each do |id|
          interest = Models::Interest[id]
          next unless interest

          recipient.add_interest(interest)
        end

        Workers::NewRecipientNotify.perform_async(recipient.id)

        erb :subscribe_confirm, locals: {
          recipient: recipient,
          next_digest_at: recipient.schedule.next_occurrence.to_time
        }
      end

      get '/subscriptions/:token/unsubscribe' do
        recipient = Models::Recipient.find(token: params[:token])
        error 404 unless recipient

        recipient.delete

        erb :unsubscribe_confirm
      end

      get '/digests/sample' do
        interests_ids = params.fetch('interests') do
          Models::Interest.published.select(:id)
        end

        digest = Models::Digest.new(created_at: Time.now)
        links = Models::Link.ranked(interests: interests_ids)
        digest.links.concat(links)

        delivery = Delivery.new(digest, sample: true, unsubscribe: false)
        delivery.html
      end

      get '/digests/:id' do
        digest = Models::Digest[params[:id]]
        error 404 unless digest

        delivery = Delivery.new(digest, unsubscribe: false)
        delivery.html
      end

      def form_locals(form:)
        {
          interests: Models::Interest.published,
          form: form
        }
      end
    end
  end
end
