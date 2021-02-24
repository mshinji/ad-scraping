class ScrapingNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "scraping_notifications_#{current_company.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def notice(data)
    ActionCable.server.broadcast "scraping_notifications_#{current_company.id}", message: data['message']
  end
end
