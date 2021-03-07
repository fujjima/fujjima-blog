class Admin::ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end
end
