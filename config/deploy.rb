# config valid only for current version of Capistrano
lock "3.7.2"

set :application, "teachbase_sample"
set :group, 'apps'
set :user, 'roller'
set :repo_name, fetch(:application)
set :repo_url, ->{ "git@github.com:pandamako/#{fetch :repo_name}.git" }
set :deploy_user, 'deploy'

set :keep_releases, 5
# set :format, :pretty
set :log_level, :info
# set :pty, true

set :linked_files, %w(config/database.yml config/secrets.yml)
set :linked_dirs, %w(log tmp/pids tmp/cache tmp/sockets tmp/sessions public/assets public/system)

set :file_permissions_paths, %w(tmp/pids log tmp/cache/assets public/system)
set :file_permissions_users, Array(fetch :user)
set :file_permissions_groups, Array(fetch :group)

set :rails_env, fetch(:stage)
set :default_stage, fetch(:stage)

Airbrussh.configure do |config|
  config.truncate = false
end

def current_branch
  ENV['BRANCH'] || `git rev-parse --abbrev-ref HEAD`.chomp
end

def bundle_exec command, witin_path = "#{self.deploy_to}/current"
  execute "sudo -u #{fetch :application} -H zsh -l -c \"source /home/#{fetch :application}/.rvm/scripts/rvm && cd #{witin_path} && RAILS_ENV=#{fetch :rails_env} bundle exec #{command}\""
end

namespace :test do
  task :git do
    on roles(:app), in: :sequence, wait: 5 do
      execute "git ls-remote #{fetch :repo_url}"
    end
  end

  task :bundle do
    on roles(:app), in: :sequence, wait: 5 do
      bundle_exec "rake -T"
    end
  end
end

namespace :deploy do
  desc "Reload the database with seed data"
  task :seed do
    on roles(:app) do
      bundle_exec "rake db:seed RAILS_ENV=#{fetch :stage}", release_path
    end
  end

  desc "Restart memcached to cleanup application cache"
  task :reset_cache do
    on roles(:app) do
      execute "sudo /etc/init.d/memcached restart"
    end
  end

  namespace :file do
    task :lock do
      on roles(:app) do
        execute "touch /tmp/deploy_#{fetch :application}_#{fetch :stage}.lock"
      end
    end

    task :unlock do
      on roles(:app) do
        execute "rm /tmp/deploy_#{fetch :application}_#{fetch :stage}.lock"
      end
    end
  end
end

namespace :unicorn do
  desc "Stop unicorn"
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo /etc/init.d/#{fetch :application}_#{fetch :stage} stop"
    end
  end

  desc "Start unicorn"
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo /etc/init.d/#{fetch :application}_#{fetch :stage} start"
    end
  end

  desc "Restart unicorn"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo /etc/init.d/#{fetch :application}_#{fetch :stage} upgrade"
    end
  end
end

after 'deploy:starting', 'deploy:file:lock'
after 'deploy:published', 'deploy:file:unlock'

after 'deploy:finishing', 'deploy:cleanup'

after 'deploy:published', 'deploy:set_permissions:chmod'
after 'deploy:published', 'deploy:set_permissions:chown'
after 'deploy:published', 'deploy:set_permissions:chgrp'

after 'deploy:published', 'unicorn:restart'
