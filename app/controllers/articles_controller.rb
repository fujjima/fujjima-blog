class ArticlesController < GeneralController
  PER_PAGE = 7

  def index
    @articles = paginate(Article.published.order(published_at: 'DESC'))
  end

  def archives
    @articles = if params[:year] && params[:month]
                  paginate(Article.published
                                  .get_by_month(params[:year], params[:month])
                                  .sort_by(&:published_at))
                elsif params[:year] && !params[:month]
                  paginate(Article.published
                                  .get_by_year(params[:year])
                                  .sort_by(&:published_at))
                end

    render :index
  end

  def tags
    @articles = paginate(Article.tagged_by(params['tag_name']))
    render :index
  end

  private

  # TODO: 単純にarticlesを渡すだけにしたい（並び順についてはここでよしなにやって欲しい）
  def paginate(ordered_articles)
    Kaminari.paginate_array(ordered_articles)
            .page(params[:page])
            .per(PER_PAGE)

  end
end
