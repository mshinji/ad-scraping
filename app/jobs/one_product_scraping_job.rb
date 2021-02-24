class OneProductScrapingJob < ApplicationJob
  include Rails.application.routes.url_helpers
  queue_as :default

  after_perform do |job|

    ActionCable.server.broadcast("scraping_notifications_#{company.id}", { message: message, url: url })
  end

  def perform(product, company)
    return 'Hello'

    retry_count = 0
    begin
      selenium = AmazonSeleniumScraping::SeleniumDriver.new
      @driver = selenium.driver(product)
      wait = Selenium::WebDriver::Wait.new(timeout: 20)
      # return scraping_history.failed_scraping('selenium webdriver is nil') if driver.nil?
      raise 'selenium webdriver is nil' if @driver.nil?

      @driver.get(Constants::SCRAPE_BASE_URL + product.asin_code + Constants::SUFFIX)

      # Sellerを表示するボタンをクリック
      offers_link = wait.until { @driver.find_element(:xpath, '//a[contains(@href, "offer-listing")]') }
      offers_link.click
      wait.until { @driver.find_element(:id, 'aod-container') }

      # 公式Sellerを表示
      if has_official_seller?
        @driver.find_element(:id, 'aod-pinned-offer-show-more-link').click
      end

      # 最後の結果が出るまでもっと見るをクリック
      while !has_end_of_results?
        current_seller_length = find_sellers.length
        @driver.execute_script('document.querySelector("#aod-show-more-offers").click()')
        wait.until { find_sellers.length > current_seller_length }
      end

      @reseller_params = find_sellers.map do |node|
        next puts node.text.strip unless get_seller_id(node.attribute(:href)) && node.displayed?

        { seller_id: get_seller_id(node.attribute(:href)), name: node.text.strip }
      end

      @reseller_params = @reseller_params.compact
      @reseller_params = @reseller_params.uniq { |param| param[:seller_id] }
      puts @reseller_params

      # return scraping_history.failed_scraping('reseller_params are size of zero.') if @reseller_params.size.zero?
      raise 'reseller_params are size of zero.' if @reseller_params.size.zero?

      puts "first scraping #{@reseller_params.size}"
      seller_scraping
    rescue StandardError => e
      # Selejium::WebDriver::Error::SessionNotCreatedError: session not created from tab crashed in heroku
      message = e
      puts e
      retry_count += 1
      # スクレイピング出来なくても4回までは実行する
      retry if retry_count <= 3
      return
    ensure
      @driver&.quit
      puts '================================================'
      scraping_history.failed_scraping(message) if retry_count > 3
    end

    # 該当productの更新前のreseller.idを取得
    previous_product_resale_sum = product.resale_number
    official_seller_ids = product.company.distributor_ids.push(product.company.seller_id)
    @reseller_params.uniq!

    ActiveRecord::Base.transaction do
      product_resellers = @reseller_params.map do |reseller|
        # 販売している会社が自分自身または代理店であればスキップ
        next if official_seller_ids.include?(reseller[:seller_id])

        # seller_idで検索し、resellerが存在する場合はひも付けだけ行う
        find_by_reseller = Reseller.active.find_by_seller_id(reseller[:seller_id])
        if find_by_reseller.blank?
          # 商品に紐づくresellerの作成
          create_reseller = Reseller.create(reseller)
          product.resellers << create_reseller
          create_reseller.reseller_histories.create(name: reseller[:name])
          ProductReseller.find_by(product_id: product.id, reseller_id: create_reseller.id)
        else
          # Amazon上の名前とDB上の名前が変わっていた場合更新する
          if reseller[:name] != find_by_reseller.name
            find_by_reseller.update(name: reseller[:name], previous_name: find_by_reseller.name)
            find_by_reseller.reseller_histories.create(name: reseller[:name])
          end
          ProductReseller.find_or_create_by(product_id: product.id, reseller_id: find_by_reseller.id)
        end
      end

      # スクレイピングしたデータに元データがなければstatus: fine
      update_product_reseller_status(product)
      product.update(product_update_columns)
      product.create_scraping_count(@reseller_params.size - 1, product_resellers) unless (@reseller_params.size - 1).zero?

      # お知らせを作成
      Info.scraped_info(product.reload, previous_product_resale_sum, product.company)
    end

    scraping_history.completed_scraping
  end

  private

  def has_official_seller?
    @driver.find_elements(:id, 'aod-pinned-offer-show-more-link').length > 0 \
    && @driver.find_element(:id, 'aod-pinned-offer-show-more-link').displayed?
  end

  def has_end_of_results?
    @driver.find_elements(:id, 'aod-end-of-results').length > 0 \
    && @driver.find_element(:id, 'aod-end-of-results').displayed?
  end

  def find_sellers
    @driver.find_elements(:xpath, '//*[@id="aod-offer-soldBy"]//a[contains(@href, "seller=")]')
  end

  def product_update_columns
    status = @reseller_params.size == 1 ? :fine : :resale
    { resale_number: @reseller_params.size - 1, status: status }
  end

  def get_seller_id(url)
    # url変わる可能性あり
    /seller=(.*?)&+/ =~ url ? $1 : nil
  end

  def seller_scraping
    retry_count = 0
    @reseller_params.map do |reseller|
      @driver.get(Constants::RESELLER_BASE_URL + reseller[:seller_id])
      # reseller情報をセット
      reseller.store(:operation_manager, get_seller_info('運営責任者名:'))
      reseller.store(:tel_number, get_seller_info('電話番号:'))
      # 質問するボタンのurl文字列取得
      question_url = @driver.find_element(:xpath, "//span[@id='seller-contact-button']/span/a")
      reseller.store(:marketplace_id, get_marketplace_id(question_url.attribute(:href))) if question_url.present?
    rescue StandardError => e
      puts 'There was an error scraped any question button.'
      puts e
      retry_count += 1
      retry if retry_count <= 2
    end

    puts "seller scraping #{@reseller_params.size}"
  end

  def get_marketplace_id(url)
    /marketplaceID=/ =~ url
    $'.match(/&/).pre_match
  end

  # 運営責任者を取得
  def get_seller_info(text)
    node = @driver.find_elements(:xpath, "//span[@class='a-list-item']").map(&:text).select { |el| /#{text}/ =~ el }
    return '' if node.empty?

    node.first.match(/:/).post_match
  end

  def update_product_reseller_status(product)
    # scrapingで取ってきたreseller.seller_id
    seller_ids = @reseller_params.map { |params| params[:seller_id] }
    puts "update_reseller #{@reseller_params.size}"

    # DBに存在するresellerと照らし合わせる
    product.product_resellers.active.includes(:reseller).find_each do |product_reseller|
      seller_id = product_reseller.reseller.seller_id.strip
      seller_ids.include?(seller_id) ? product_reseller.became_worse : product_reseller.became_better
    end
  end

  def set_host
    if Rails.env.production?
      'http://amazon-reseller-production.tk'
    elsif Rails.env.staging?
      'http://test.amazon-reseller-production.tk'
    else
      'http://localhost:3000'
    end
  end
end
