# coding: utf-8
# multistage setting
require 'capistrano/ext/multistage'

set :stages, %w(production staging)

# default stage name
set :default_stage, "staging"

# color output setting
require 'capistrano_colors'
set :application, "fbb"

# RVM
require "rvm/capistrano"
set :rvm_ruby_strig, "1.9.3"

# git settings
set :scm, :git
set :repository, "git://github.com/kajiwara3/blog.git"
set :branch, "master"
set :deploy_via, :remote_cache

# ssh settings
set :use_sudo, false
set :default_run_options, :pty => true
ssh_options[:forward_agent] = true
set :normalize_asset_timestamps, false
set :scm_verbose, true
set :keep_releases, 10

namespace :deploy do
  desc "cause Passenger to initiate a restart"

  task :restart, roles: :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path}; rake db:seed RAILS_ENV=#{rails_env}"
  end

  desc "Copy shared config files to current application."
  task :config_symlink do
    run "ln -s /home/ic-mente/config/database.yml #{release_path}/config/database.yml"
  end

  namespace :db do
    desc "Create #{rails_env} Database"
    task :create do
      puts "\n\n=== Creating the Production Database! ===\n\n"
      run "cd #{current_path}; rake db:create RAILS_ENV=#{rails_env}"
      system "cap deploy:set_permissions"
    end
  end
end

desc "install the necessary prerequisites"
task :bundle_install, :roles => :app do
  run "cd #{release_path} && bundle install"
end

after "deploy:update_code", :bundle_install

# 本コマンド実行時に、デプロイ先に配置してあるdatabase.ymlのシンボリックリンクを設定する
after "deploy:update"
# 本コマンド実行時に、デプロイ先に配置してあるdatabase.ymlのシンボリックリンクを設定する
#before "deploy:migrate", "deploy:config_symlink"
