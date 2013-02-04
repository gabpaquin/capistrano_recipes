require "rvm/capistrano"
set :rvm_ruby_string, "1.9.3-p0@#{application}"
set :rvm_type, :system
set :branch, "master"

role :web, "ekohe.com"
role :app, "ekohe.com"
role :db,  "ekohe.com", :primary => true
 
set :deploy_to, "/var/www/#{application}"

set :rails_env, 'production'

task :configure, :roles => :web do
  run "ln -s #{shared_path}/config/database.yml #{current_release}/config/database.yml"
  run "ln -s #{shared_path}/bundler_gems #{current_release}/bundler"
  run "rm -rf #{current_release}/.bundle && ln -s #{shared_path}/dot_bundle #{current_release}/.bundle"
  run "cd #{current_release}; sudo -u www-data sh -c 'source /usr/local/lib/rvm && rvm #{rvm_ruby_string} && bundle install --path bundler'"
  run "rm -rf #{current_release}/public/uploads && ln -s #{shared_path}/uploads #{current_release}/public/uploads"
end

after 'deploy:update_code', :configure
after 'configure', 'deploy:assets:precompile'

namespace :deploy do
  [:start, :stop, :restart].each do |action|
    task action do
      run "sudo monit -g #{application}_ruby #{action} all"
    end
  end

  namespace :assets do
    task :precompile do
      our_rake "RAILS_GROUPS=assets assets:precompile"
    end
  end

  task :migrate do
    our_rake "db:migrate"
  end
end

def our_rake(task)
  run "cd #{current_release}; sudo -u www-data sh -c 'source /usr/local/lib/rvm && rvm #{rvm_ruby_string} && RAILS_ENV=production rake #{task}'"
end