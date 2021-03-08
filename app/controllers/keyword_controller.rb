class KeywordController < ApplicationController
  before_action :set_keyword, only: %i(edit update destroy one_scraping)

  def index
    @q = Keyword.order(:status).ransack(params[:q])
    @keywords = @q.result(distinct: true).page(params[:page])
  end

  def new
    @keyword = Keyword.new
  end

  def create
    @keyword = Keyword.new(create_params)
    if @keyword.save
      redirect_to url_for(action: :index), notice: 'キーワードを追加しました。'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @keyword.update(update_params)
      redirect_to url_for(action: :index), notice: 'キーワードを編集しました。'
    else
      render :edit
    end
  end

  def destroy
    if @keyword.destroy
      redirect_to url_for(action: :index), notice: 'キーワードを削除しました。'
    else
      render :index
    end
  end

  def one_scraping
    OneKeywordScrapingJob.perform_later(@keyword)
  end

  def all_scraping
    AllKeywordsScrapingJob.perform_later()
  end

  private

  def set_keyword
    @keyword = Keyword.find_by(id: params[:id])
  end

  def create_params
    params.require(:keyword).permit(:status, :name)
  end

  def update_params
    params.require(:keyword).permit(:status, :name)
  end
end
