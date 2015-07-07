ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'

require 'minitest/reporters'
Minitest::Reporters.use!(Minitest::Reporters::DefaultReporter.new(color: true))

require 'webmock/minitest'

WebMock.allow_net_connect!
WebMock.disable_net_connect!(allow_localhost: true)

require 'database_cleaner'

require 'sidekiq/testing'
Sidekiq::Testing.fake!

require './app'

require 'sequel/extensions/migration'

Sequel::DATABASES.each do |db|
  Sequel::Migrator.apply(db, './db/migrations')
end

class MiniTest::Spec
  def stub_stem(value, &block)
    BlueSkies::Stemmer.stub(:stem, value, &block)
  end

  before(:each) { DatabaseCleaner.start }
  after(:each) { DatabaseCleaner.clean }
end
