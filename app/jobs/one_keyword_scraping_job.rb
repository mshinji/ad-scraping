class OneKeywordScrapingJob < ApplicationJob
  include Rails.application.routes.url_helpers
  include KeywordScraping
  queue_as :default

  after_perform do |job|
    keyword = job.arguments.first
    message = "【#{keyword.name}】の\nスクレイピングが終了しました。\n\n結果を表示しますか？"
    Rails.application.routes.default_url_options[:host] = set_host
    url = url_for(controller: :ad, action: :show, id: keyword.id)
    ActionCable.server.broadcast("scraping_notification", { message: message, id: keyword.id, url: url })
  end

  def perform(keyword)
    scraping([keyword], job_id)
  end
end
