module KeywordHelper
  def keyword_status_lists
    {
      t('enums.keyword.status.active') => :active,
      t('enums.keyword.status.disabled') => :disabled
    }
  end

  def one_scraping_btn(keyword)
    if keyword.scraping_histories.present_exec_one_keyword?
      link_to t('label.OneScraping'), url_for(action: :one_scraping, id: keyword.id),
        class: 'btn btn-sm btn-success scraping-button disabled loading', data: { id: keyword.id, name: keyword.name }, remote: true
    else
      link_to t('label.OneScraping'), url_for(action: :one_scraping, id: keyword.id),
        class: 'btn btn-sm btn-success scraping-button', data: { id: keyword.id, name: keyword.name }, remote: true
    end
  end

  def all_scraping_btn
    if ScrapingHistory.present_exec_all_keywords?
      link_to t('label.AllScraping'), url_for(action: :all_scraping),
        class: 'btn btn-sm btn-success scraping-button disabled loading', data: { id: 0, name: '全件' }, remote: true
    else
      link_to t('label.AllScraping'), url_for(action: :all_scraping),
        class: 'btn btn-sm btn-success scraping-button', data: { id: 0, name: '全件' }, remote: true
    end
  end

  def keyword_status_color(keyword)
    if keyword.active?
      'alert alert-success'
    elsif keyword.disabled?
      'alert alert-danger'
    end
  end
end
