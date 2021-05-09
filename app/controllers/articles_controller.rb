class ArticlesController < ApplicationController
  def index
    # 1画面に7〜8記事ずつ記載する
    # 1記事の表示範囲は文字数で
    @articles = Article.published
  end
end
