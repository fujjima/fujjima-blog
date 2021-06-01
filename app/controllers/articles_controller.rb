class ArticlesController < GeneralController

  def index
    # TODO: 1画面に6〜7記事ずつ記載する
    @articles = Article.published.order(published_at: 'DESC')
  end

  def archives
    @articles = if params[:year] && params[:month]
                  Article.published.get_by_month(params[:year], params[:month])
                elsif params[:year] && !params[:month]
                  Article.published.get_by_year(params[:year])
                end

    render :index
  end

  def tags
    render :index
  end
end
