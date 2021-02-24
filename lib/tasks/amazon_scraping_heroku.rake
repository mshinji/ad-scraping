namespace :amazon_scraping_heroku do
  desc '転売ヤーがいないかASINコードを使って確認'
  task check_reseller: :environment do
    puts "#{Time.zone.now} Start cheking reseller"

    Company.all.each(&:scraping)

    puts "#{Time.zone.now} Finished cheking reseller"
  end

  # private
  #
  # def slack_notification(company_id, token, channel)
  #   messages = "【転売情報】\n\n"
  #   Slack.configure do |config|
  #     config.token = ENV[token]
  #   end
  #
  #   company = Company.find_by(id: company_id)
  #   return if company.blank? || company.products&.active&.pluck(:resale_number)&.inject(&:+)&.zero?
  #
  #   messages << "*#{company.name}*\n"
  #   company.products.active.each do |product|
  #     messages << "  商品名:   #{product.name}: #{product.status_i18n}\n"
  #     product.resellers.each do |reseller|
  #       # ヒアドキュメント使ったら何故かエラーになる
  #       messages << "    ・転売会社名：#{reseller.name}\n"
  #       messages << "    ・url：https://www.amazon.co.jp/sp?_encoding=UTF-8&seller=#{reseller.seller_id}\n\n"
  #     end
  #   end
  #
  #   Slack.chat_postMessage(channel: channel, text: messages, icon_emoji: ':new:', username: '転売通知君')
  # end
end
