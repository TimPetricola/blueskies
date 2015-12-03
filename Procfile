web: bundle exec puma -C ./lib/puma.rb
worker: bundle exec sidekiq -r ./app.rb -q digest,2 -q default -c 7
console: bundle exec pry -r ./app
dev: webpack --config webpack.config.js --watch
