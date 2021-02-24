require File.expand_path(File.dirname(__FILE__) + '/environment')

set :environment, Rails.env
set :output, "#{Rails.root}/log/cron.log"
set :path, '/home/www/AdScraping'

# Company.active.find_each do |company|
  # notify_time = company.notification_interval
  # next unless company.notification_status.notify?

  # time = notify_time.to_f / 60
  # every notify_time.minutes do
    # command "su -l rdwbocungelt5 -c cd /home/www/AdScraping && RAILS_ENV=#{Rails.env} /home/rdwbocungelt5/.rbenv/shims/bundle exec rake amazon_scraping:check_reseller[#{company.id}]"
  # end
# end

#every 60.minutes do
#  command "su -l rdwbocungelt5 -c cd /home/www/AdScraping && RAILS_ENV=#{Rails.env} /home/rdwbocungelt5/.rbenv/shims/bundle exec rails amazon_scraping_heroku:check_reseller"
#end
