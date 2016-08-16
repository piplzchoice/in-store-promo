require 'sidekiq'

db_number = 5

case Rails.env
when "development"
  db_number = 6
when "staging"
  db_number = 7
when "production"
  db_number = 8
end    

Sidekiq.configure_client do |config|
  config.redis = { :namespace => "DW-#{Rails.env}", :url => "redis://127.0.0.1:6379/#{db_number}" }
end

Sidekiq.configure_server do |config|
  config.redis = { :namespace => "DW-#{Rails.env}", :url => "redis://127.0.0.1:6379/#{db_number}" }
end