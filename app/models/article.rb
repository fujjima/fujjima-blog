class Article < ApplicationRecord
  has_many :article_tags, dependent: :destroy
  has_many :tags, through: :article_tags

  validates :published, inclusion: [true, false]

  before_save :update_published_at, if: :will_save_change_to_published?
  scope :published, -> { where(published: true) }
  scope :group_by_monthly, -> { group_by { |article| article.published_at&.strftime('%Y/%m') } }
  scope :group_by_yearly, -> { group_by { |article| article.published_at&.strftime('%Y') } }
  scope :get_by_month, -> (year, month) {
    where('EXTRACT(YEAR FROM published_at) = :year AND EXTRACT(MONTH FROM published_at) = :month', year: year, month: month)
  }
  scope :get_by_year, -> (year) {
    where('EXTRACT(YEAR FROM published_at) = :year', year: year)
  }
  scope :tagged_by, -> (tag_name){ joins(:tags).where(tags: {name: tag_name}) }

  # scope :group_by_year_and_month, -> { group_by { |article| [article.published_at.strftime('%Y'), article.published_at.strftime('%Y-%m')] } }

  # XXX: hash→hash（valueのみ更新）したい場合
  # hash.map{} としてk,vへのアクセスをしやすくする
  # 最後にto_hでhashに変換し直す

  private

  def update_published_at
    return if published_in_database

    assign_attributes(published_at: Time.now)
  end
end
