Sequel.migration do
  change do
    run <<-SQL
      CREATE EXTENSION IF NOT EXISTS "hstore" WITH SCHEMA public;
    SQL

    add_column :links, :image, :hstore
  end
end
