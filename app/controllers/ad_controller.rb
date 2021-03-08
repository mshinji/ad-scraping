class AdController < ApplicationController
  def show
    @keyword = Keyword.find(params[:id])
    @q = @keyword.ads.ransack(params[:q])
    @ads = @q.result(distinct: true).page(params[:page])
  end
end
