require "bundler/capistrano"

load "config/deploy/recipes/base"
load "config/deploy/recipes/nginx"
load "config/deploy/recipes/unicorn"
load "config/deploy/recipes/postgresql"
load "config/deploy/recipes/nodejs"
load "config/deploy/recipes/rbenv"
load "config/deploy/recipes/check"
load "config/deploy/recipes/rake"

server "116.226.42.238", :web, :app, :db, primary: true

set :application, "r8"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :default_environment, { 'PATH' => "/home/deployer/.rbenv/shims:/home/deployer/.rbenv/bin:$PATH" }
set :bundle_flags, "--deployment --quiet --binstubs --shebang ruby-local-exec"

set :branch, "stable"

before 'deploy:restart', 'deploy:assets:precompile'
before 'deploy:restart', 'deploy:link_uploads'

namespace :deploy do
  namespace :assets do
    task :precompile do
      our_rake "RAILS_GROUPS=assets assets:precompile"
    end
  end

  task :link_uploads do
    run "rm -rf #{current_release}/public/uploads && ln -s #{shared_path}/uploads #{current_release}/public/uploads"
  end

  task :migrate do
    our_rake "db:migrate"
  end
end

def our_rake(task)
  run "cd #{current_release}; RAILS_ENV=production rake #{task}"
end