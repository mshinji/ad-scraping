require 'rake'
require './lib/ext/scraping_module'
Rails.application.load_tasks

class TasksController < GuestController
  # GAE環境でcronを動かすために使う
  # 一時間に一回動かす
  def scraping
    return head :not_found unless request.headers['X-Appengine-Cron']

    Company.all.each do |company|
      next unless company.notification_status.notify?

      AmazonScraping.scraping(company.id)
      AmazonScraping.send_mail(company.id)
      # system "rake amazon_scraping:check_reseller[#{company.id}]"
      slack_notification(company.id)
    end

    sleep(1)
    head :no_content
  end

  private

  def slack_notification(company_id)
    messages = "【転売情報】\n\n"
    Slack.configure do |config|
      config.token = ENV['HIDE_SLACK_API_TOKEN']
    end

    company = Company.find_by(id: company_id)
    return if company.blank? || company.products&.active&.pluck(:resale_number)&.inject(&:+)&.zero?

    messages << "*#{company.name}*\n"
    company.products.active.each do |product|
      messages << "  商品名:   #{product.name}: #{product.status_i18n}\n"
      product.resellers.each do |reseller|
        # ヒアドキュメント使ったら何故かエラーになる
        messages << "    ・転売会社名：#{reseller.name}\n"
        messages << "    ・url：https://www.amazon.co.jp/sp?_encoding=UTF-8&seller=#{reseller.seller_id}\n\n"
      end
    end

    Slack.chat_postMessage(channel: 'CDU90PSJF', text: messages, icon_emoji: ':new:', username: '転売通知君')
  end
end
