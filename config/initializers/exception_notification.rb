require 'exception_notification/rails'

ExceptionNotification.configure do |config|
  # Ignore additional exception types.
  # ActiveRecord::RecordNotFound, Mongoid::Errors::DocumentNotFound, AbstractController::ActionNotFound and ActionController::RoutingError are already added.
  config.ignored_exceptions += %w{ActionView::MissingTemplate}

  # Adds a condition to decide when an exception must be ignored or not.
  # The ignore_if method can be invoked multiple times to add extra conditions.
  config.ignore_if do |exception, options|
    Rails.env.development?
  end

  # Notify Slack
  # https://api.slack.com/docs/message-attachments
  config.add_notifier :slacky, {
    webhook_url: 'https://hooks.slack.com/services/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',
    channel: '02_amazon撲滅_error',
    username: 'exception_slacky',
    color: Rails.env.production? ? :danger : :warning,
    custom_fields: [
      {
        title: 'User Agent',
        value: ->(req) { req.user_agent },
        short: false,
        after: 'IP Address'
      },
      {
        title: 'Environment',
        value: ->(req) { Rails.env },
        short: true,
        after: 'Host'
      }
    ]
  }
end
