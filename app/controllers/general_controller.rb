# 一般画面用の共通処理を記載する
# 一般画面用例外処理

class GeneralController < ApplicationController
  before_action :set_archives

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