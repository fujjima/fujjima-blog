class SearchController < GeneralController
  def index
    respond_to do |format|
      format.html
      format.json do
        articles = Article.published.search(params[:q]).order(published_at: :desc)
        render json: articles.map { |article| { title: article.title, url: article_path(slug: article.slug) } }
      end
    end
  end
end
