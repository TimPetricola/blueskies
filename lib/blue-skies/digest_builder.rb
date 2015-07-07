module BlueSkies
  module DigestBuilder
    extend self

    def create(recipient: recipient)
      links = Models::Link.ranked_for_recipient(recipient)
      return if links.empty?

      digest = Models::Digest.create(recipient: recipient)
      links.each do |link|
        digest.add_link(link)
      end

      digest
    end
  end
end
