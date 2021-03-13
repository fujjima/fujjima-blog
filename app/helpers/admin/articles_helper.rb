module Admin::ArticlesHelper

  def fotmat_date(date)
    date&.strftime('%Y-%m-%d')
  end
end
