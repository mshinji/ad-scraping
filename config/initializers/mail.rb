if Rails.env.production?
  ActionMailer::Base.perform_caching = true
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.default_url_options = { host: ENV['HOST_ADDR'] }
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.smtp_settings = {
    address: 'smtp.sendgrid.net',
    domain: ENV['HOST_ADDR'],
    port: 2525,
    user_name: ENV['SENDGRID_USERNAME'],
    password: ENV['SENDGRID_PASSWORD'],
    authentication: :plain,
    enable_starttls_auto: true,
  }
elsif Rails.env.development?
  ActionMailer::Base.delivery_method = :letter_opener
elsif Rails.env.staging?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.default_url_options = { host: 'amazon-ban-staging.herokuapp.com' }
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.smtp_settings = {
    user_name: ENV['SENDGRID_USERNAME'],
    password: ENV['SENDGRID_PASSWORD'],
    domain: 'herokuapp.com',
    address: 'smtp.sendgrid.net',
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true
  }
else
  ActionMailer::Base.delivery_method = :test
end
