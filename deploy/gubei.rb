require "bundler/capistrano"

load "config/deploy/recipes/base"
load "config/deploy/recipes/nginx"
load "config/deploy/recipes/unicorn"
load "config/deploy/recipes/postgresql"
load "config/deploy/recipes/nodejs"
load "config/deploy/recipes/rbenv"
load "config/deploy/recipes/check"
load "config/deploy/recipes/rake"
load "config/deploy/recipes/extra"

server "gubei.r8.ekohe.com", :web, :app, :db, primary: true
# 106.186.18.104 - Japanese gateway
# 58.246.194.26 - Static IP Gubei's office
ssh_options[:port] = 22 # 2084 (japanese gateway) # OR 2052

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