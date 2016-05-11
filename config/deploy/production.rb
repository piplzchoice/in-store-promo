# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

role :app, %w{deploy@104.236.182.64}
role :web, %w{deploy@104.236.182.64}
role :db,  %w{deploy@104.236.182.64}

set :tmp_dir, "/home/deploy/tmp"
set :default_env, { rvm_bin_path: '/home/deploy/.rvm/bin' }

set :deploy_to, '/home/deploy/ism'
set :rvm_ruby_version, 'ruby-2.1.1@ism'

set :linked_files, %w{config/database.yml .env config/environments/production.rb config/secrets.yml config/initializers/carrierwave.rb}

server '104.236.182.64', user: 'deploy', roles: %w{web app}, my_property: :my_value
