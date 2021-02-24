require 'sidekiq'
require 'sidekiq/scheduler'
require 'redis-namespace'

Sidekiq::Scheduler.dynamic = true

Sidekiq.configure_server do |config|
  config.redis = case Rails.env
                 when 'production'
                   { url: 'redis://10.142.0.3:6379', namespace: "sidekiq.AdScraping:#{Rails.env}" }
                 when 'staging'
                   { url: 'redis://h:pf1c935caa660b674bf074ef195f45082ec594adfa921c065e00603fd77424f54@ec2-3-94-67-220.compute-1.amazonaws.com:28709', namespace: "sidekiq.AdScraping:#{Rails.env}" }
                 else
                   { url: 'redis://redis:6379', namespace: "sidekiq.AdScraping:#{Rails.env}" }
                 end
end

Sidekiq.configure_client do |config|
  config.redis = case Rails.env
                 when 'production'
                   { url: 'redis://10.142.0.3:6379', namespace: "sidekiq.AdScraping:#{Rails.env}" }
                 when 'staging'
                   { url: 'redis://h:pf1c935caa660b674bf074ef195f45082ec594adfa921c065e00603fd77424f54@ec2-3-94-67-220.compute-1.amazonaws.com:28709', namespace: "sidekiq.AdScraping:#{Rails.env}" }
                 else
                   { url: 'redis://redis:6379', namespace: "sidekiq.AdScraping:#{Rails.env}" }
                 end
end

Sidekiq.schedule = YAML.load_file("#{Rails.root}/config/sidekiq_scheduler.yml")
