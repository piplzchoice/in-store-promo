require 'sidekiq'

db_number = 1

case Rails.env
when "development"
  db_number = 2
when "staging"
  db_number = 3
when "production"
  db_number = 4
end    

Sidekiq.configure_client do |config|
  config.redis = { :namespace => "ISM-#{Rails.env}", :url => "redis://127.0.0.1:6379/#{db_number}" }
end

Sidekiq.configure_server do |config|
  config.redis = { :namespace => "ISM-#{Rails.env}", :url => "redis://127.0.0.1:6379/#{db_number}" }
end