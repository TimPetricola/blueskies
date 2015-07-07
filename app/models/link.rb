module BlueSkies
  module Models
    class Link < Sequel::Model
      TWO_WEEKS = 60 * 60 * 24 * 14
      THIRTY_DAYS = 60 * 60 * 24 * 30

      dataset_module do
        def unextracted
          where(extracted_at: nil)
        end

        def need_share_count_udpate
          where('last_curated_at >= ?', Time.now - THIRTY_DAYS)
        end

        def ranked_for_recipient(recipient, limit: 5, curated_after: Time.now - TWO_WEEKS)
          ranked(
            exclude: recipient.digested_links_ids_dataset,
            interests: recipient.interests_ids_dataset,
            limit: limit,
            curated_after: curated_after
          )
        end

        def ranked(exclude: nil, interests: nil, limit: 5, curated_after: Time.now - TWO_WEEKS)
          interests_score = 1

          # Included values will be multiplied to rank links
          scoring = []

          # Curators score
          scoring << proc {
            log(count(:curators_links__curator_id) + 1)
          }

          # Date score
          scoring << proc {
            Sequel./(
              1,
              log(
                Sequel.*(
                  100,
                  (
                    :now.sql_function.extract('EPOCH') -
                    :created_at.cast(:timestamp).extract('EPOCH')
                  ) / (60 * 60 * 24) + 1
                )
              )
            )
          }

          # Shares score
          scoring << proc {
            log(
              Sequel.case(
                {{share_count: nil} => 0}, :share_count
              ) + 2
            )
          }

          ds = select(:links__id)
            .exclude(links__extracted_at: nil)
            .join(:curators_links, link_id: :links__id)
            .group(:links__id)
            .order(:rank.desc, :links__created_at.desc)
            .limit(limit)

          # Links curated after given date only
          if curated_after
            ds = ds.where { links__last_curated_at > curated_after }
          end

          # Links with given interests only
          # with_interests = recipient.interests_ids_dataset
          if interests
            ds = ds
              .join(:interests_links, link_id: :links__id)
              .where(interests_links__interest_id: interests)

            scoring << proc {
              log(count(:interests_links__interest_id) + 1)
            }
          end

          # Exclude given links
          # exclude = recipient.digested_links_ids_dataset
          if exclude
            ds = ds.exclude(links__id: exclude)
          end

          ds = ds.select_append do
            Sequel.*(*scoring.map{|s| Sequel.expr(s)}).as(:rank)
          end

          # Get ranked links ids
          ids = ds.map { |r| r[:id] }

          # # Needs to be reordered as a WHERE id IN (...) does not keep order
          # # TODO: move this to SQL
          where(id: ids).to_a.sort_by{ |l| ids.index(l.id) }
        end
      end

      many_to_many :curators
      many_to_many :interests
      many_to_many :digests

      # Convert Hash to hstore before storing
      def image=(data)
        data = data.hstore if data.respond_to?(:hstore)
        super(data)
      end

      def image
        i = super
        i && Image.new(i['url'], i['width'], i['height'], i['color'])
      end

      def extract!
        extracted = Extractor.extract(url)

        extracted.keywords.each do |keyword|
          interest = Interest.find_or_create_by_name(keyword)
          add_interest(interest)
        end

        update_all(
          title: extracted.title,
          description: extracted.description,
          extracted_at: Time.now,
          image: extracted.images.empty? ? nil : extracted.images.first.to_h
        )
      end

      def update_share_count!
        info = FacebookLink.info(url)
        update_all(share_count: info.share_count) if info.share_count
      end

      def description_sanitized
        d = description.to_s
        d = '' if d.scan(/https?:/).length > 2
        d = '' if d.length < 10
        d
      end

      private

      # Override to ensure uniqueness
      def _add_curator(curator)
        return curator if curators.include?(curator)
        super(curator)
      end

      # Override to ensure uniqueness
      def _add_interest(interest)
        return interest if interests.include?(interest)
        super(interest)
      end
    end
  end
end
