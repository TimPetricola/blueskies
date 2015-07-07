require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs.push 'test'
  t.pattern = 'test/**/*_test.rb'
  t.warning = false
  t.verbose = true
end

task default: [:test]

task :app do
  require './app'
end

namespace :db do
  task preload: :app do
    require 'sequel'
    Sequel.extension :migration
  end

  desc 'Run DB migrations'
  task migrate: :preload do
   require 'sequel/extensions/migration'
   database = Sequel.connect(BlueSkies::App.database)
   Sequel::Migrator.apply(database, 'db/migrations')
  end

  desc 'Rollback migration'
  task rollback: :preload do
    database = Sequel.connect(BlueSkies::App.database)
    version  = (row = database[:schema_info].first) ? row[:version] : nil
    Sequel::Migrator.apply(database, 'db/migrations', version - 1)
  end

  desc 'Drop the database'
  task drop: :preload do
    database = Sequel.connect(BlueSkies::App.database)
    database.tables.each do |table|
      database.run("DROP TABLE #{table} CASCADE")
    end
  end

  desc 'Dump the database schema'
  task dump: :preload do
    database = Sequel.connect(BlueSkies::App.database)
    `sequel -d #{database.url} > db/schema.rb`
    `pg_dump --schema-only #{database.url} > db/schema.sql`
  end
end
