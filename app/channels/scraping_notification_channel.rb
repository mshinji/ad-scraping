class ScrapingNotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "scraping_notification"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
