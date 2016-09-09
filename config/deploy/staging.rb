# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

role :app, %w{staging@104.236.182.64}
role :web, %w{staging@104.236.182.64}
role :db,  %w{staging@104.236.182.64}

set :branch, 'development'
set :tmp_dir, "/home/staging/tmp"
set :default_env, { rvm_bin_path: '/home/staging/.rvm/bin' }

set :deploy_to, '/home/staging/ism'
set :rvm_ruby_version, 'ruby-2.1.1@ism'

set :linked_files, %w{config/database.yml config/secrets.yml}
# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

server '104.236.182.64', user: 'staging', roles: %w{web app}, my_property: :my_value
