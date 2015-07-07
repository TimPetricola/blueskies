require 'rubygems'
require 'bundler'

Bundler.require
$: << File.expand_path('../', __FILE__)
$: << File.expand_path('../app', __FILE__)
$: << File.expand_path('../lib', __FILE__)

require 'sinatra/base'
require 'sinatra/sequel'
require 'rollbar/middleware/sinatra'

require 'lib/blue-skies'
require 'app/models'
require 'app/workers'
require 'app/forms'
require 'app/routes'

require 'sidekiq'
require 'sidekiq/api'

module BlueSkies
  class App < Sinatra::Base
    configure do
      I18n.enforce_available_locales = false

      set :database, lambda {
        ENV['DATABASE_URL'] || "postgres://localhost:5432/blueskies_#{environment}"
      }
      Sequel.connect(settings.database)
      Sequel::Model.db.extension(:pg_array)

      if ENV['ROLLBAR_ACCESS_TOKEN']
        Rollbar.configure do |config|
          config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']
        end
      end
    end

    use Rollbar::Middleware::Sinatra if ENV['ROLLBAR_ACCESS_TOKEN']

    use BlueSkies::Routes::Home
  end
end
