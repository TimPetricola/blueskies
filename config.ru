require './app'
require 'sidekiq/web'
require './lib/sidekiq'

run BlueSkies::App

map '/sidekiq' do
  if ENV.key?('SIDEKIQ_WEB_USER')
    use Rack::Auth::Basic, 'Protected Area' do |username, password|
      username == ENV.fetch('SIDEKIQ_WEB_USER') && password == ENV.fetch('SIDEKIQ_WEB_PWD')
    end
  end

  run Sidekiq::Web
end

Sequel::DATABASES.each(&:disconnect) if defined?(Sequel::Model)
