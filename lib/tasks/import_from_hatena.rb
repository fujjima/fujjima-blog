require 'time'

class ArticleText
  attr_accessor :article

  def initialize article
    @article = article
  end
  
  def column_mather matcher
    return if article.empty?
    # dateの時は空白が必要
    article.match(/#{matcher}:\s(.*)\n/)[1].gsub(" ", "")
  end

  # text本文専用
  # 開始： \nBODY:\n
  # 終了： \n-----\n
  def test_body_mather
    return if article.empty?
    article.match(/\nBODY:\n([\s\S]*)\n-----\n$/)[1]
  end
end

def date_convert date
  # 年月日と時間の間に半角スペースはない前提
  Time.strptime(date, '%m/%d/%Y%H:%M:%S')
end

articles = []

begin
  File.open('hatenablog.com.export.txt') do |file|
    file.read.split('--------').each do |article_text|
      # コメント部分は抽出対象に含めない
      article_text.gsub!(/COMMENT:\n[\s\S]*\n-----\n/, '')
      
      # 一記事ずつ配列に格納（文字列）
      articles << article_text
    end
    # 配列のlastが改行のみの場合削除しておく
    articles.pop if articles.last.match?(/\n/)
  end
rescue SystemCallError => e
  %Q(class=#{e.class}, messag=#{e.message})
end

# 一記事ずつオブジェクトに分離
import_datas = articles.map do |article_text|
  article = ArticleText.new(article_text)
  {
    title: article.column_mather("TITLE"),
    published_at: date_convert(article.column_mather("DATE")),
    published: article.column_mather("STATUS") == "Publish",
    text: article.test_body_mather,
    slug: '',
  }
end

ActiveRecord::Base.transaction do
  import_datas.each do |import_data|
    Rails.application.config.import_hatena_logger.info("import記事タイトル: #{import_data[:title]}")
    article = Article.new(import_data)

    # はてなブログからのインポート時のみ、という超限定的な状況でしか使用されないためコールバックを手動でスキップしている
    article.skip_update_published_at = true
    article.save!
  end
end
