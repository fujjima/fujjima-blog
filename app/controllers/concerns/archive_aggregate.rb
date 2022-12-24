module ArchiveAggregate
  extend ActiveSupport::Concern
  extend Memoist

  included do
    # https://www.ruby-forum.com/t/using-helper-method-from-a-mixin-module/111817
    helper_method :load_archives
  end

  # FIXME: Articleという文脈を含んでいる時点で、Articleモデルに定義しておくべきものでは
  #   そもそもControllerにincludeするのが目的なら、Concernなのでは
  def load_archives
    Article.published
           .group_by_yearly
           .map { |year, articles| { year: year, total: articles.count, months: aggregate_by_month(articles) } }
           .sort_by{ |aggregator| aggregator[:year] }.reverse
  end
  memoize :load_archives

  private

  def aggregate_by_month(articles)
    articles.group_by { |article| article.published_at.strftime('%Y/%m') }
            .map { |month, blogs| { month: month, count: blogs.count } }
            .sort_by { |result| result[:month] }
            .reverse
  end
end