class ScrapingsController < GuestController
  def index
    @histories = current_company.scraping_histories.includes(:product).references(:product).order(start_at: :desc)
  end

  def count_index
    @product_resellers = ProductReseller.includes(:reseller).where(scraping_count_id: params[:id])
  end
end
