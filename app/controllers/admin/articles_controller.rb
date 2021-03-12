class Admin::ArticlesController < AdminController
  before_action :set_article, only: %w[edit update destroy]
  def index
    @articles = Article.all
  end

  def edit; end

  def update
    @article.assign_attributes(article_params)
    if @article.save
      redirect_to admin_articles_path, notice: "successed to update"
    else
      flash.now[:alert] = "failed to update"
      render :edit
    end
  end

  def destroy; end

  private

  def article_params
    params.require(:article).permit(:title, :text, :published, :slug)
  end

  def set_article
    @article = Article.find(params[:id])
  end
end
