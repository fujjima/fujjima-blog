class ArchivesController < GeneralController
  # 公開済み記事を 年 => { 月 => [記事] } の形で新しい順に保持する
  def index
    @archives = Article.published
                       .where.not(published_at: nil)
                       .order(published_at: :desc)
                       .group_by { |article| article.published_at.year }
                       .transform_values { |articles| articles.group_by { |article| article.published_at.month } }
  end
end
