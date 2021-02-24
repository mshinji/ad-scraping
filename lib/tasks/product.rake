namespace :product do
  desc 'resale_numberの更新'
  task update_resale_number: :environment do
    puts "### #{Time.zone.now} Start Update Resale Number ###"
    Product.active.each_with_index do |product, i|
      i += 1
      resale_number = product.product_resellers.active.joins(:reseller)
                             .where.not(resellers: { seller_id: product.company.seller_id }).resale.count
      status = resale_number.positive? ? :resale : :fine
      product.update(resale_number: resale_number, status: status)
      puts "#{i}: #{product.name} 転売数[#{resale_number}]"
    end
    puts "### #{Time.zone.now} Finished Update Resale Number ###"
  end
end
