source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

gem 'rails', '~> 6.1.1'
gem 'pg'
gem 'unicorn'
gem 'webpacker', '~> 5.0'
gem 'jbuilder', '~> 2.7'
gem 'selenium-webdriver'
gem 'slack-api'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'dotenv-rails'
gem 'enum_help'
gem 'whenever'
gem 'exception_notification'
gem 'exception_notification-slacky'
gem 'clipboard-rails'
gem 'ransack'
gem 'kaminari'
gem 'order_as_specified'
gem 'redis'
gem 'redis-namespace'
gem 'redis-rails'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'faker'

group :development, :test do
  gem 'annotate'
  gem 'awesome_print'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'capybara', '>= 3.26'
  gem 'onkcop', require: false
  gem 'pry-byebug'
  gem 'pry-doc'
  gem 'pry-rails'
  gem 'rack-mini-profiler', '~> 2.0', require: false
  gem 'rails-controller-testing'
  gem 'rubocop', require: false
  gem 'simplecov'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'web-console', '>= 4.1.0'
  gem 'letter_opener'
end

group :test do
  gem 'database_cleaner'
end

group :staging do
  gem 'puma', '~> 5.0'
end

group :development, :test, :staging do
  gem 'rack-dev-mark'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
