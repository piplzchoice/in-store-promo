# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'ism'
set :repo_url, 'git@github.com:piplzchoice/in-store-promo.git'
set :tmp_dir, "/home/deploy/tmp"

# set :rvm_type, :system
# set :default_env, { rvm_bin_path: '/home/deploy/.rvm/bin' }

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/deploy/ism'
set :rvm_ruby_version, 'ruby-2.1.1@ism'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml .env}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/assets public/uploads public/sitemaps}

set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart  

end
