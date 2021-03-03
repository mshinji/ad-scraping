class AllKeywordsScrapingJob < ApplicationJob
  include Rails.application.routes.url_helpers
  include KeywordScraping
  queue_as :default

  after_perform do |job|
    keyword = job.arguments.first
    message = "【全体】の\nスクレイピングが終了しました。\n\n結果を表示しますか？"
    Rails.application.routes.default_url_options[:host] = set_host
    url = url_for(controller: :keyword, action: :index)
    ActionCable.server.broadcast("scraping_notification", { message: message, id: 0, url: url })
  end

  def perform()
    keywords = Keyword.where(status: :active)
    scraping(keywords, job_id)
  end
end
