module BlueSkies
  module Models
    class Curator < Sequel::Model
      many_to_many :links

      def curate!
        urls = FacebookFetcher.fetch(facebook_identifier, last_curated_at)

        urls.each do |url|
          link = Link.find_or_create(url: url)
          link.add_curator(self)
        end

        update(last_curated_at: Time.now)
      end
    end
  end
end
