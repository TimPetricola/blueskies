Sequel.migration do
  up do
    run <<-SQL
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
    SQL

    create_table(:curators) do
      column :id, 'uuid', default: Sequel::LiteralString.new('uuid_generate_v4()'), primary_key: true, null: false
      column :facebook_identifier, String, null: false
      column :last_curated_at, Time

      column :created_at, Time
      column :updated_at, Time
    end

    create_table(:recipients) do
      column :id, 'uuid', default: Sequel::LiteralString.new('uuid_generate_v4()'), primary_key: true, null: false
      column :email, String, unique: true, null: false
      column :schedule, String, text: true
      column :next_digest_job_id, String
      column :token, String, index: true, null: false, unique: true

      column :created_at, Time
      column :updated_at, Time
    end

    create_table(:interests) do
      column :id, 'uuid', default: Sequel::LiteralString.new('uuid_generate_v4()'), primary_key: true, null: false
      column :name, String, null: false, unique: true
      column :stems, 'text[]', index: { type: :gin }, default: '{}'
      column :published, 'boolean', default: false, null: false

      column :created_at, Time
      column :updated_at, Time
    end

    create_table(:links) do
      column :id, 'uuid', default: Sequel::LiteralString.new('uuid_generate_v4()'), primary_key: true, null: false
      column :url, String, unique: true, null: false, index: true
      column :title, String
      column :description, String, text: true
      column :extracted_at, Time
      column :last_curated_at, Time
      column :share_count, Bignum

      column :created_at, Time
      column :updated_at, Time
    end

    create_table(:digests) do
      column :id, 'uuid', default: Sequel::LiteralString.new('uuid_generate_v4()'), primary_key: true, null: false
      foreign_key :recipient_id, :recipients, type: 'uuid', key: :id, index: true, on_delete: :cascade

      column :created_at, Time
      column :updated_at, Time
    end

    create_table(:curators_links) do
      foreign_key :curator_id, :curators, type: 'uuid', key: :id, index: true, on_delete: :cascade
      foreign_key :link_id, :links, type: 'uuid', key: :id, index: true, on_delete: :cascade

      primary_key [:curator_id, :link_id], name: :curators_links_pk
    end

    create_table(:digests_links) do
      foreign_key :digest_id, :digests, type: 'uuid', key: :id, index: true, on_delete: :cascade
      foreign_key :link_id, :links, type: 'uuid', key: :id, index: true, on_delete: :cascade

      primary_key [:digest_id, :link_id], name: :digests_links_pk
    end

    create_table(:interests_links) do
      foreign_key :interest_id, :interests, type: 'uuid', key: :id, index: true, on_delete: :cascade
      foreign_key :link_id, :links, type: 'uuid', key: :id, index: true, on_delete: :cascade

      primary_key [:interest_id, :link_id], name: :interests_links_pk
    end

    create_table(:interests_recipients) do
      foreign_key :interest_id, :interests, type: 'uuid', key: :id, index: true, on_delete: :cascade
      foreign_key :recipient_id, :recipients, type: 'uuid', key: :id, index: true, on_delete: :cascade

      primary_key [:interest_id, :recipient_id], name: :interests_recipients_pk
    end

    run <<-SQL
      CREATE FUNCTION fn_link_last_curated_at() RETURNS trigger AS $$
        BEGIN
          UPDATE links SET last_curated_at = CURRENT_TIMESTAMP WHERE id = NEW.link_id;
          RETURN NEW;
        END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER trg_link_last_curated_at
        AFTER INSERT
        ON curators_links
        FOR EACH ROW
        EXECUTE PROCEDURE fn_link_last_curated_at();
    SQL
  end

  down do
    run <<-SQL
      DROP TRIGGER trg_link_last_curated_at ON curators_links;
      DROP FUNCTION fn_link_last_curated_at();
    SQL

    drop_table(:interests_recipients)
    drop_table(:interests_links)
    drop_table(:digests_links)
    drop_table(:curators_links)
    drop_table(:digests)
    drop_table(:links)
    drop_table(:interests)
    drop_table(:recipients)
    drop_table(:curators)
  end
end
