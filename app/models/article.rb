class Article < ApplicationRecord
  # 公開日時：publishedがfalse→trueになった日に変更される
  validates :published, inclusion: [true, false]
  validates :slug, presence: true
end
