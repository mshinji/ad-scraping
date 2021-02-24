namespace :sidekiq do
  pid_file = "#{Rails.root}/tmp/pids/sidekiq.pid"

  desc 'Sidekiq stop'
  task :stop do
    puts '#### Trying to stop Sidekiq Now !!! ####'
    if File.exist?(pid_file)
      puts "Stopping sidekiq now #PID-#{File.readlines(pid_file).first}..."
      system 'bundle exec sidekiqctl stop tmp/pids/sidekiq.pid'
    else
      puts '--- Sidekiq Not Running !!!'
    end
  end

  desc 'Sidekiq start'
  task :start do
    puts 'Starting Sidekiq...'
    system "bundle exec sidekiq --environment #{Rails.env} -C config/sidekiq.yml -d -L log/sidekiq.log"
    sleep(2)
    puts "Sidekiq started #PID-#{File.readlines(pid_file).first}."
  end

  desc 'Sidekiq restart'
  task :restart do
    puts '#### Trying to restart Sidekiq Now !!! ####'
    Rake::Task['sidekiq:stop'].invoke
    Rake::Task['sidekiq:start'].invoke
    puts '#### Sidekiq restarted successfully !!! ####'
  end
end
