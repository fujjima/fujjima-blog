class Admin::ArticlesController < AdminController
  before_action :set_article, only: %w[edit update destroy]

  def new
    @article = Article.new
  end

  def index
    @articles = Article.all
  end

  def edit; end

  def create
    @article = Article.new(article_params)
    if @article.save
      redirect_to admin_articles_path, notice: "successed to create"
    else
      flash.now[:alert] = "failed to create"
      render :edit
    end
  end

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
