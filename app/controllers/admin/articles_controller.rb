class Admin::ArticlesController < AdminController
  include Taggable
  before_action :set_article, only: %w[edit update destroy]

  def new
    @article = Article.new
    @tags = Tag.all
  end

  def index
    @articles = Article.includes(:tags)
                       .order(:id)
  end

  def edit
    @tag_names = Tag.pluck(:name)
  end

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
    ActiveRecord::Base.transaction do
      # TODO: タグの新規作成を待つ必要性とその方法
      tag_names_ary = tag_names_to_ary(params[:tags])
      Tag.insert_new_tag(tag_names_ary)
      @article.tags.replace(from_tag_names_ary_to_tag_instances_ary(tag_names_ary))

      @article.assign_attributes(article_params)
      if @article.save
        redirect_to admin_articles_path, notice: "successed to update"
      else
        flash.now[:alert] = "failed to update"
        render :edit
      end
    end
  end

  def destroy
    if @article.destroy
      redirect_to admin_articles_path, notice: "successed to delete"
    else
      flash.now[:alert] = "failed to delete"
      render :index
    end
  end

  private

  # TODO: 理想はtagsについても[]で受け取れるようにすること
  def article_params
    params.require(:article).permit(:title, :text, :published, :slug)
  end

  def set_article
    @article = Article.find(params[:id])
  end
end
