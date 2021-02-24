namespace :product_scraping do
  desc '商品ごとにスクレイピング'
  task :check_product_reseller, ['id'] => :environment do |_, args|
    begin
      product = Product.active.find(args[:id])
    rescue StandardError
      puts 'IDが見つかりませんでした。'
    end

    sleep(3)
    product.scraping
  end
end
