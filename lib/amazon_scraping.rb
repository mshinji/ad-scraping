require 'nokogiri'
require 'open-uri'
require 'readline'

class AmazonScraping
  BASE_URL = 'https://www.amazon.jp/gp/offer-listing/'.freeze
  SUFFIX_URL = '?ref=olp_page&f_new=true'.freeze

  # url = 'https://www.amazon.co.jp/gp/offer-listing/B017PGCGV2'
  # url = 'https://www.amazon.co.jp/gp/offer-listing/B00GMZ02IM'

  class << self
    # とりあえず標準入力でASINコードを取得
    def input_asin
      asin_list = []

      i = 1
      loop do
        puts "【商品#{i}】"
        asin_list << Readline.readline('ASINコードを入力してください：', true)
        break if Readline.readline('ASINコードの入力を終了しますか？(y/n)：', true) == 'y'

        i += 1
      end

      asin_list
    end

    # 標準入力で入力されたASINコードを受け取ってスクレイピング
    # TODO データベースからASINコードを引っ張ってきて引数に渡す
    def scraping(asin_list)
      result = {}

      asin_list.each_with_index do |code, idx|
        puts "===================== 商品#{idx + 1} ====================="

        url = BASE_URL + code + SUFFIX_URL
        charset = nil

        begin
          html = open(url) do |f|
            charset = f.charset # 文字種別を取得
            f.read # htmlコードを代入
          end
        rescue StandardError => e
          puts '400 Bad Request'
          puts "RequestUrl : '#{url}'"
          next
        end

        doc = Nokogiri::HTML.parse(html, nil, charset) # Nokogiriを使ってhtmlを分解

        # ドキュメント全体を検索する場合は「//をつける」
        # cssメソッドでエレメントを取得できる
        # inner_textでタグ内のテキスト文を返す
        seller_list = []
        doc.xpath("//h3[@class='a-spacing-none olpSellerName']").each do |node|
          # p node.css('a').inner_text
          seller_list << node.css('a').inner_text
        end

        if seller_list.empty?
          puts '404 not found'
          puts "RequestUrl : '#{url}'"
          next
        end

        puts "出品者数：#{seller_list.size}"
        if seller_list.size == 1
          result[code] = { seller: 1, resale: false }
          puts '転売者なし'
        else
          result[code] = { seller: seller_list.size, resale: true }
          puts '転売者あり'
        end
      end

      result
    end
  end

  asin_list = input_asin
  puts ' '
  result = scraping(asin_list)
  puts '================================================='
  puts ' '
  puts result
  puts ' '
end
