class TagsController < GeneralController
  def index
    @article_counts = ArticleTag.joins(:article)
                                .merge(Article.published)
                                .group(:tag_id)
                                .count
    # 公開記事が1件もないタグは表示しない
    @tags = load_tags.select { |tag| @article_counts[tag.id].to_i.positive? }
  end
end
