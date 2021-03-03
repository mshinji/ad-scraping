module AdHelper
  def ad_status_lists
    {
      t('enums.ad.status.initial') => :initial,
      t('enums.ad.status.again') => :again,
      t('enums.ad.status.gone') => :gone
    }
  end

  def ad_engine_lists
    {
      t('enums.ad.engine.google') => :google,
      t('enums.ad.engine.yahoo') => :yahoo
    }
  end

  def ad_status_color(ad)
    if ad.initial?
      'alert alert-success'
    elsif ad.again?
      'alert alert-warning'
    elsif ad.gone?
      'alert alert-danger'
    end
  end
end
