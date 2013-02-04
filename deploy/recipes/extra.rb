namespace :extra do
  desc "Install extra packages."
  task :install, roles: :web do
    run "#{sudo} apt-get install libxml2-dev libxslt1-dev imagemagick"
  end
  after "deploy:install", "extra:install"
end
