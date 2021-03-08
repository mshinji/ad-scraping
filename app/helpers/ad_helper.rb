module AdHelper
  def ad_engine_lists
    {
      t('enums.ad.engine.google') => :google,
      t('enums.ad.engine.yahoo') => :yahoo
    }
  end
end
