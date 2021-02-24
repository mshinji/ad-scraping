module HomeHelper
  def product_status_color(product)
    if product.fine? || resale_reseller_count(product).zero?
      'alert alert-success'
    else
      'alert alert-danger'
    end
  end

  def display_scrape(product)
    t(".#{product.scrape}")
  end

  def product_reseller_status_color(product_reseller)
    if product_reseller.resale?
      'alert alert-danger'
    elsif product_reseller.warning?
      'alert alert-warning'
    elsif product_reseller.fine?
      'alert alert-success'
    elsif product_reseller.bought?
      'alert alert-info'
    end
  end

  def resale_reseller_count(product)
    product.product_resellers.joins(:reseller)
           .where(deleted: false, status: :resale)
           .where.not('resellers.seller_id like ?', "%#{current_company.seller_id}").count
  end

  def product_reseller_select_status_lists
    {
      t('enums.product_reseller.status.fine') => 'fine',
      t('enums.product_reseller.status.resale') => 'resale',
      t('enums.product_reseller.status.warning') => 'warning',
      t('enums.product_reseller.status.bought') => 'bought',
    }
  end

  def product_reseller_select_first_flg_lists
    {
      t('enums.product_reseller.first_flg.checked') => true,
      t('enums.product_reseller.first_flg.uncheck') => false,
    }
  end

  def bought_details_status_options
    {
      t('activerecord.attributes.bought_detail.arrived') => 'arrived',
      t('activerecord.attributes.bought_detail.refund') => 'refund',
    }
  end

  def product_reseller_select_status_options
    {
      t('enums.reseller.status.fine') => 0,
      t('enums.reseller.status.resale') => 1,
      t('enums.reseller.status.warning') => 2,
      t('enums.reseller.status.bought') => 3,
    }
  end

  def product_select_step_options
    {
      t('enums.product.step.first_dealing') => 0,
      t('enums.product.step.completed') => 1,
    }
  end

  def black_list_display(black_list)
    if black_list.id.present?
      [t('label.Edit_object', target: t('activerecord.models.black_list')),
       t('label.Update'), black_list.black_list_category]
    else
      [t('label.Register_object', target: t('activerecord.models.black_list')), t('label.Register')]
    end
  end

  def black_list_btn(black_list_title, bl_category)
    if bl_category.present?
      content_tag :button, class: 'btn btn-sm border ml-auto mr-2', style: "background-color: #{bl_category.bg_color}", 'data-toggle' => 'modal', 'data-target' => '#modal-black-list' do
        concat content_tag :i, nil, class: 'fas fa-exclamation-triangle mr-1'
        concat bl_category.name
      end
    else
      content_tag :button, class: 'btn btn-dark btn-sm ml-auto mr-2', 'data-toggle' => 'modal', 'data-target' => '#modal-black-list' do
        concat content_tag :i, nil, class: 'fas fa-exclamation-triangle mr-1'
        concat black_list_title
      end
    end
  end

  def black_list_decorate(company_category_ids, bl_categories_hash)
    @bg_color, @option = if company_category_ids && company_category_ids[current_company.id]
                           [bl_categories_hash[company_category_ids[current_company.id]], { data: { confirm: t('label.Open_black_list?') }, class: 'reseller-name' }]
                         elsif company_category_ids
                           ['', { data: { confirm: t('label.Open_other_black_list?') }, class: 'reseller-name' }]
                         else
                           ['', { class: 'reseller-name' }]
    end
  end

  def scraping_btn_display(product)
    if product.scraping_histories.present_exec?
      link_to t('products.reseller_index.exec_scraping'), '#', class: 'btn btn-sm btn-info disabled'
    else
      link_to t('products.reseller_index.scraping'), url_for(action: :product_scraping, id: product.id), id: 'scraping-button', class: 'btn btn-sm btn-info', remote: true
    end
  end

  def unarrived_and_unrefunded_display(product, bought_details_hash)
    content_tag :div do
      concat unarrived_cnt_display(product, bought_details_hash)
      concat unrefunded_cnt_display(product, bought_details_hash)
    end
  end

  def unarrived_cnt_display(product, bought_details_hash)
    unarrived_cnt = bought_details_hash[product.id][:unarrived_cnt]
    str = t('.unarrived_cnt') + unarrived_cnt.to_s + t('.item')
    if unarrived_cnt.positive?
      link_to str, url_for(controller: 'products', action: :bought_detail_index, id: product.id, s: 'unarrived'), class: 'right-border', style: 'color: red;'
    else
      content_tag :span, str, class: 'text-info right-border'
    end
  end

  def unrefunded_cnt_display(product, bought_details_hash)
    unrefunded_cnt = bought_details_hash[product.id][:unrefunded_cnt]
    str = t('.unrefunded_cnt') + unrefunded_cnt.to_s + t('.item')
    if unrefunded_cnt.positive?
      link_to str, url_for(controller: 'products', action: :bought_detail_index, id: product.id, s: 'unrefunded'), style: 'color: red;'
    else
      content_tag :span, str, class: 'text-info'
    end
  end
end
