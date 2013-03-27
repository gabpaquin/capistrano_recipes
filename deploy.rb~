set :stages, %w(staging gubei xujiahui pudong)
set :default_stage, 'staging'
require 'capistrano/ext/multistage'

set :application, "r8"
ssh_options[:forward_agent] = true
set :repository,  "gitolite@106.186.18.104:r8.git"
set :scm, :git

set :use_sudo, false
set :deploy_via, :remote_cache
default_run_options[:pty] = true

after "deploy", "deploy:cleanup" #keep only the last 5 releases

task :backup, :roles => :web do
  run "#{deploy_to}/backups/backup_db.sh"
end

before 'deploy:update_code', :backup
