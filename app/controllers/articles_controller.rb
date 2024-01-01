class ArticlesController < GeneralController
  PER_PAGE = 7

  def index
    @articles = paginate(Article.published
                                .preload(:tags)
                                .sort_by(&:published_at)
                                .reverse!)

  end

  def show
    @article = Article.published.find_by(slug: params[:slug])
  end

  def archives
    @articles = if params[:year] && params[:month]
                  paginate(Article.published
                                  .get_by_month(params[:year], params[:month])
                                  .sort_by(&:published_at)
                                  .reverse!)
                elsif params[:year] && !params[:month]
                  paginate(Article.published
                                  .get_by_year(params[:year])
                                  .sort_by(&:published_at)
                                  .reverse!)
                end

    render :index
  end

  def tags
    @articles = paginate(Article.tagged_by(params['tag_name']))
    render :index
  end

  # TODO: 外部サイト作ったら消す
  def question; end

  private

  # TODO: 単純にarticlesを渡すだけにしたい（並び順についてはここでよしなにやって欲しい）
  def paginate(ordered_articles)
    Kaminari.paginate_array(ordered_articles)
            .page(params[:page])
            .per(PER_PAGE)

  end
end
