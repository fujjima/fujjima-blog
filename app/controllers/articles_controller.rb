class ArticlesController < ApplicationController
  before_action :set_archives, only: %w[index archives tags]


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

  private

  def set_archives
    @archives = Article.published
                       .group_by_yearly
                       .map { |year, articles| { year: year, total: articles.count, months: aggregate_by_month(articles) } }
  end

  def aggregate_by_month(articles)
    articles.group_by { |article| article.published_at.strftime('%Y/%m') }
            .map { |month, blogs| { month: month, count: blogs.count } }
            .sort_by { |result| result[:month] }
            .reverse!
  end
end
