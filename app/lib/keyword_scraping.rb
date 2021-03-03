module KeywordScraping
  def scraping(keywords, job_id)

    if keywords.length == 1
      scraping_history = ScrapingHistory.exec_scraping(scraping_type: :one_keyword, keyword_id: keywords[0].id, job_id: job_id)
    else
      scraping_history = ScrapingHistory.exec_scraping(scraping_type: :all_keywords, job_id: job_id)
    end

    keywords.each do |keyword|
      puts "========= #{ keyword.name } ========="
      selenium = AdSeleniumDriver.new
      @driver = selenium.driver(keywords)
      @wait = Selenium::WebDriver::Wait.new(timeout: 20)
      @keyword = keyword

      google_ad_params = []
      yahoo_ad_params = []
      begin
        5.times do
          google_ad_params.concat(google_ads)
          yahoo_ad_params.concat(yahoo_ads)
        end

        google_ad_params = google_ads.uniq { |ad| ad[:url] }
        yahoo_ad_params = yahoo_ads.uniq { |ad| ad[:url] }
      rescue StandardError => e
        message = e
        scraping_history.failed_scraping(message)
        @driver&.quit
        return
      end

      @driver&.quit

      ActiveRecord::Base.transaction do
        # 該当keywordのstatusを全てgoneにする
        Ad.where(keyword_id: keyword.id).update_all(status: :gone)
        [:google, :yahoo].each do |engine|
          ad_params = engine == :google ? google_ad_params : yahoo_ad_params

          new_ad_params = ad_params.map do |ad_param|
            find_by_url = Ad.find_by(url: ad_param[:url], engine: engine, keyword_id: keyword.id)
            if find_by_url.blank?
              # 存在しない場合は新規作成
              Ad.create(name: ad_param[:name], url: ad_param[:url], engine: engine,
              status: :initial, keyword_id: keyword.id, job_id: job_id)
            else
              # 存在する場合は更新
              find_by_url.update(name: ad_param[:name], status: :again, job_id: job_id)
            end
          end
        end
      end

      scraping_history.completed_scraping
    end
  end

  private

  def google_ads
    @driver.get(Constants::GOOGLE_BASE_URL + @keyword.name)
    ads = @wait.until { @driver.find_elements(:xpath, '//*[@aria-label="広告"]//a') }
    ad_params = ads.map do |node|
      next if node.attribute(:href).include?('https://www.google.com')

      {
        url: node.attribute(:href),
        name: node.text.gsub(/\s+/, '').split('広告·')[0]
      }
    end

    ad_params.compact
  end

  def yahoo_ads
    []
  end

  def set_host
    if Rails.env.production?
      nil
      # 'http://amazon-reseller-production.tk'
    elsif Rails.env.staging?
      nil
      # 'http://test.amazon-reseller-production.tk'
    else
      'http://localhost:3000'
    end
  end
end
