namespace :amazon_scraping do
  desc '転売ヤーがいないかASINコードを使って確認'
  task :check_reseller, ['id'] => :environment do |_, args|
    puts "#{Time.zone.now} Start cheking reseller"

    begin
      company = Company.find(args[:id])
      company.scraping
    rescue StandardError => e
      puts e
    end

    puts "#{Time.zone.now} Finished cheking reseller"
  end
end
