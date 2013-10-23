namespace :run_rake do
  task :invoke do
    run "cd #{current_path} && RAILS_ENV=production rake #{ENV['COMMAND']}"
  end
end