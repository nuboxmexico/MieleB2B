# config valid only for current version of Capistrano
#lock "3.8.1"

#set :stage, 'production'
set :application, "Miele"
set :repo_url, "git@bitbucket.org:garage-labs/miele.git"

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
#set :branch, :develop

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/html/miele"
set :rvm_type, :user
set :rvm_ruby_version, '2.3.1'
set :rvm_binary, '~/.rvm/bin/rvm'
set :rvm_bin_path, "$HOME/bin"
set :default_env, { rvm_bin_path: '~/.rvm/bin' }
set :user, "ubuntu"
set :use_sudo, false
set :deploy_via, :copy

# Default value for :format is :airbrussh.
# set :format, :airbrussh
set :format, :pretty

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto
set :format, :pretty
set :rails_env, fetch(:stage)

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 3

#set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

set :passenger_environment_variables, { :path => '/usr/lib/ruby/vendor_ruby/phusion_passenger/bin:$PATH' }
set :passenger_restart_command, '/usr/lib/ruby/vendor_ruby/phusion_passenger/bin/passenger-config restart-app'

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      branch = fetch(:stage) == :staging ? 'develop' : fetch(:stage) == :preproduction ? 'master-clone' : 'master'
      #branch = fetch(:stage) == :staging ? 'release-3.1.0' : fetch(:stage) == :preproduction ? 'master-clone' : 'master'
      unless `git rev-parse HEAD` == `git rev-parse origin/#{branch}`
        puts "WARNING: HEAD is not the same as origin/"+branch
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:web), in: :sequence, wait: 5 do
      within release_path do

        execute :bundle, 'install'
        execute "crontab -r"
        execute :bundle, :exec, "whenever --update-crontab --set environment=#{fetch(:stage)}"
        #execute :bundle, :exec, "whenever --update-crontab"
        execute :chmod, '777 '+release_path.join('tmp/cache/').to_s
        execute :rake, "db:create RAILS_ENV=#{fetch(:stage)}"
        execute :rake, "db:migrate RAILS_ENV=#{fetch(:stage)}"
        execute :rake, "db:seed RAILS_ENV=#{fetch(:stage)}"
        execute :rake, "assets:precompile RAILS_ENV=#{fetch(:stage)}"
        execute (fetch(:stage) == :staging ? 'sudo service apache2 reload' : 'sudo service nginx restart')
      end
    end

    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        #execute "crontab -r"
        execute :bundle, 'install'
        execute "crontab -r"
        execute :bundle, :exec, "whenever --update-crontab --set environment=#{fetch(:stage)}"
        execute :chmod, '777 '+release_path.join('tmp/cache/').to_s
        execute :chmod, '777 '+release_path.join('log/').to_s
        execute :rake, "db:create RAILS_ENV=#{fetch(:stage)}"
        execute :rake, "db:migrate RAILS_ENV=#{fetch(:stage)}"
        #execute :rake, "assets:precompile RAILS_ENV=#{fetch(:stage)}"
        #execute 'bundle exec rake -s sitemap:refresh RAILS_ENV=production'
        execute (fetch(:stage) == :staging ? 'sudo service apache2 reload' : 'sudo service nginx restart')
      end
    end
  end
  
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
  
  before :starting,     :check_revision
#  after  :finishing,    :compile_assets
#  after  :finishing,    :cleanup
after  :finishing,    :restart
end