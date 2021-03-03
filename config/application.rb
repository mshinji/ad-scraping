require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AdScraping
  class Application < Rails::Application
    # config.load_defaults 5.2
    config.load_defaults 6.1

    config.i18n.default_locale = :ja
    config.time_zone = 'Tokyo'

    # 以下は状況に応じて変更する
    # config.autoload_paths =+ %W(#{config.root}/lib)
    # config.autoload_paths += %W(#{config.root}/lib/ext)
    # ファイル読み込み本番用
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.generators do |g|
      g.assets false
      g.test_framework false
    end

    config.action_view.field_error_proc = proc { |html_tag, instance| html_tag }

    config.active_record.cache_versioning = false

    config.active_job.queue_adapter = :sidekiq
  end
end
