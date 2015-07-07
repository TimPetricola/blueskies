module BlueSkies
  module Models
    class Interest < Sequel::Model
      dataset_module do
        def search(q)
          q = Stemmer.stem(q)
          where(Sequel.like(Sequel.pg_array_op(:stems).join(' ; '), "%#{q}%"))
        end

        def first_by_stem(stem)
          where(Sequel.pg_array_op(:stems).contains([stem])).limit(1).first
        end

        def published
          where(published: true)
        end
      end

      many_to_many :recipients
      many_to_many :links

      def self.find_or_create_by_name(name)
        stem = Stemmer.stem(name)
        first_by_stem(stem) || create(stems: [stem], name: name)
      end

      def before_save
        self.stems = [Stemmer.stem(name)] if stems.empty?
        super
      end

      def stems
        super || []
      end

      def add_stem(stem)
        return if stems.include?(stem)
        self.stems.push(stem)
        save(columns: [:stems, :updated_at])
      end

      def merge_from(origin)
        # Merge links
        origin.links.each { |link| link.add_interest(self) }

        # Merge recipients
        origin.recipients.each { |recipient| recipient.add_interest(self) }

        # Merge stems
        self.stems = stems | origin.stems
        save(columns: [:stems, :updated_at])

        origin.delete
      end

      def merge_into(dest)
        dest.merge_from(self)
      end

      def publish!
        update_all(published: true)
      end
    end
  end
end
