namespace :redis do

  desc "Install redis"
  task :install do
    ["cd /tmp",
     "wget http://download.redis.io/redis-stable.tar.gz",
     "tar xvzf redis-stable.tar.gz", 
     "cd redis-stable", 
     "make", 
     "sudo cp /tmp/redis-stable/src/redis-benchmark /usr/local/bin/",
     "sudo cp /tmp/redis-stable/src/redis-cli /usr/local/bin/",
     "sudo cp /tmp/redis-stable/src/redis-server /usr/local/bin/",
     "sudo cp /tmp/redis-stable/redis.conf /etc/",
     "sudo sed -i 's/daemonize no/daemonize yes/' /etc/redis.conf",
     "sudo sed -i 's/^pidfile \/var\/run\/redis.pid/pidfile \/tmp\/redis.pid/' /etc/redis.conf"].each {|cmd| run cmd}
  end
  after "deploy:install", "redis:install"

  desc "Generate the database.yml configuration file."
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "redis.yml.erb", "#{shared_path}/config/redis.yml"
  end
  after "deploy:setup", "redis:setup"  

  desc "Symlink the redis.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/redis.yml #{release_path}/config/redis.yml"
  end
  after "deploy:finalize_update", "redis:symlink"

  desc "Start the Redis server"
  task :start do
    run "redis-server /etc/redis.conf"
  end

  desc "Stop the Redis server"
  task :stop do
    run 'echo "SHUTDOWN" | nc localhost 6379'
  end

end