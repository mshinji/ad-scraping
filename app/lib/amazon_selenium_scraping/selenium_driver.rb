class AmazonSeleniumScraping::SeleniumDriver
  attr_accessor :wait, :client, :options

  def initialize
    @options = Selenium::WebDriver::Chrome::Options.new
    @client = Selenium::WebDriver::Remote::Http::Default.new
    @wait = Selenium::WebDriver::Wait.new(timeout: 10)
  end

  def driver(_product)
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    # options.add_argument("--user-agent=#{Constants::USER_AGENT_LISTS.sample}")
    options.add_argument("--user-agent=#{Faker::Internet.user_agent}")
    client.read_timeout = 120

    Selenium::WebDriver.for(:chrome, options: options, http_client: client)
  end
end
