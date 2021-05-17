class ArticlesController < ApplicationController
  def index
    # TODO: 1画面に6〜7記事ずつ記載する
    @articles = Article.published.order(published_at: 'DESC')
    @archives = Article.published
                       .group_by_yearly
                       .map { |year, articles| { year: year, total: articles.count, months: aggregate_by_month(articles) } }

  end

  def archives
  end

  def tags
  end

  private

  def aggregate_by_month(articles)
    articles.group_by { |article| article.published_at.strftime('%Y/%m') }
            .map { |month, blogs| { month: month, count: blogs.count } }
            .sort_by { |result| result[:month] }
            .reverse!
  end
end
