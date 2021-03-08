class Admin::ArticlesController < ApplicationController
  before_action :set_article, only: %w[edit update destroy]
  def index
    @articles = Article.all
  end

  def edit; end

  def update

  end

  def destroy

  end

  private

  def article_params
    params.require(:article).permit(:title, :text, :status)
  end

  def set_article
    @article = Article.find(params[:id])
  end
end
