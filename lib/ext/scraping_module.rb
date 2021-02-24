module AmazonScraping
  class << self
    def scraping(company_id)
      products = Company.find_by(id: company_id).products
      return if products.blank?

      asin_list = products.active&.pluck(:asin_code)
      asin_list.each do |code|
        url = Constants::SCRAPE_BASE_URL + code + Constants::SUFFIX
        charset = nil
        opt = {}
        opt['User-Agent'] = Constants::USER_AGENT_LISTS.sample

        puts "===================#{code}==================="
        html = url_open(url, charset, opt)
        doc = Nokogiri::HTML.parse(html, nil, charset)
        seller_name_doc = doc.xpath("//h3[@class='a-spacing-none olpSellerName']").css('a')
        pages = doc.at_xpath("//ul[@class='a-pagination']")&.css('a')

        # seller address scraping
        @reseller_params = seller_name_doc.map do |node|
          # TODO: urlが変わっている場合は通知する
          next puts node.text.strip unless get_seller_id(node[:href])

          { seller_id: get_seller_id(node[:href]), name: node.text.strip, status: 'resale' }
        end
        puts "first scraping #{@reseller_params.size}"
        next if @reseller_params.size.zero?

        # scraping pagination
        p pages
        paginate_scraping(pages, opt) unless pages.nil?
        seller_scraping(opt)

        # product & reseller update
        product = Product.active&.find_by(asin_code: code)
        next if product.nil?

        # ログにproduct name表示
        puts product.name

        # 該当productの更新前のreseller.idを取得
        previous_reseller_ids = product.resellers.where.not(status: :fine).pluck(:id)

        @reseller_params&.uniq.each do |reseller|
          # 販売している会社が自分自身であればスキップする
          next if Company.find(company_id).name == reseller[:name]

          # seller_idで検索
          found_reseller = Reseller.find_by(seller_id: reseller[:seller_id])
          # resellerが存在する場合はひも付けだけ行う
          if found_reseller
            next if ProductReseller.find_by(product_reseller_params(product, found_reseller))

            ProductReseller.create(product_reseller_params(product, found_reseller))
          else
            # 商品に紐づくresellerの作成
            product.resellers << Reseller.create(reseller)
          end
        end

        # スクレイピングしたデータに元データがなければstatus: fine
        update_reseller_status(product)
        product.update(product_update_columns)

        # お知らせを作成
        info_body = set_info_body(product.reload, previous_reseller_ids)
        if info_body.present?
          Info.create(body: info_body, company_id: company_id)
          puts info_body.html_safe
        end

        puts '================================================'
        sleep(3)
      end
    end

    def send_mail(company_id)
      company = Company.find_by(id: company_id)
      return if not_send_mail?(company)

      # TODO: send_to_company_about_resellerの第二引数を決める
      NotificationMailer.send_to_company_about_reseller(company, []).deliver
    end

    private

    def product_update_columns
      return { resale_number: 0, status: :fine } if @reseller_params.size == 1

      { resale_number: @reseller_params.size - 1, status: :resale }
    end

    def product_reseller_params(product, reseller)
      { product_id: product.id, reseller_id: reseller.id }
    end

    def not_send_mail?(company)
      company.blank? || !company.notification_status.notify? || company.products&.active&.pluck(:resale_number)&.compact&.inject(&:+)&.zero?
    end

    def get_seller_id(url)
      # url変わる可能性あり
      /seller=/ =~ url || /s=/ =~ url ? $' : nil
    end

    def paginate_scraping(pages, opt)
      charset = nil

      pages[1..-2].each do |page|
        page_url = 'https://www.amazon.jp' + page[:href]
        # user-agentを再定義
        opt['User-Agent'] = Constants::USER_AGENT_LISTS.sample

        begin
          page_html = url_open(page_url, charset, opt)
          page_doc = Nokogiri::HTML.parse(page_html, nil, charset)
          seller_doc = page_doc.xpath("//h3[@class='a-spacing-none olpSellerName']").css('a')
          seller_doc.map do |node|
            @reseller_params << { seller_id: get_seller_id(node[:href]), name: node.text.strip }
          end
        rescue StandardError => e
          puts e
          next
        end

        puts "peginate scraping #{@reseller_params.size}"
      end
    end

    def seller_scraping(opt)
      @reseller_params.map do |reseller|
        page_url = Constants::RESELLER_BASE_URL + reseller[:seller_id]
        charset = nil

        begin
          # user-agentを再定義
          opt['User-Agent'] = Constants::USER_AGENT_LISTS.sample
          html = url_open(page_url, charset, opt)
          doc = Nokogiri::HTML.parse(html, nil, charset)
          # reseller情報をセット
          reseller.store(:operation_manager, get_seller_info(doc, '運営責任者名:'))
          reseller.store(:tel_number, get_seller_info(doc, '電話番号:'))
          # 質問するボタンのurl文字列取得
          question_url = doc.css('#seller-contact-button .a-button-inner').children.first[:href]
          reseller.store(:marketplace_id, get_marketplace_id(question_url))
        rescue StandardError => e
          puts 'Question button scraped an error.'
          puts e
          next
        end
      end

      puts "seller scraping #{@reseller_params.size}"
    end

    def url_open(url, _charset, opt)
      open(url, opt) do |f|
        charset = f.charset
        f.read
      end
    rescue StandardError => e
      puts e
    end

    def get_marketplace_id(url)
      /marketplaceID=/ =~ url
      # marketplacID= よりも後ろの文字列を取得し、&とマッチさせる
      /&/ =~ $'
      # &よりも前の文字列
      $`
    end

    # 運営責任者を取得
    def get_seller_info(doc, text)
      node = doc.css("//span[@class='a-list-item']").grep(/#{text}/)
      return '' if node.empty?

      /:/ =~ node.first.children.text
      $'
    end

    def update_reseller_status(product)
      # scrapingで取ってきたreseller.name
      names = @reseller_params.map do |param|
        param[:name]
      end
      puts "update #{@reseller_params.size}"

      # DBに存在するresellerと照らし合わせる
      product.resellers.each do |reseller|
        # 転売有時スキップ
        # TODO: ResaleLogを残す
        next if reseller.resale?

        if names.include?(reseller.name.strip) && reseller.bought? || reseller.bought_fine?
          reseller.update(status: 'bought_resale')
        elsif names.include?(reseller.name.strip) && reseller.remind?
          reseller.update(status: 'remind_resale')
        elsif !names.include?(reseller.name.strip) || reseller.warning?
          reseller.update(status: 'pre_remind')
        elsif !names.include?(reseller.name.strip) || reseller.bought_resale?
          reseller.update(status: 'bought_fine')
        end
      end
    end

    def set_info_body(product, previous_reseller_ids)
      current_reseller_ids = product.resellers.where.not(status: :fine).pluck(:id)
      if current_reseller_ids.size < previous_reseller_ids.size
        "<a href='/products/#{product.id}/resellers' class='text-dark'>『#{product.name}』の転売数が<span class='text-success'>減りました</span></a>"
      elsif current_reseller_ids.size > previous_reseller_ids.size
        "<a href='/products/#{product.id}/resellers' class='text-dark'>『#{product.name}』の転売数が<span class='text-danger'>増えました</span></a>"
      elsif current_reseller_ids != previous_reseller_ids
        "<a href='/products/#{product.id}/resellers' class='text-dark'>『#{product.name}』の転売者の<span class='text-warning'>内容が変わりました</span></a>"
      end
    end
  end
end
