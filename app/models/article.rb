class Article < ApplicationRecord
  attr_accessor :skip_update_published_at

  has_many :article_tags, dependent: :destroy
  has_many :tags, through: :article_tags

  validates :published, inclusion: [true, false]

  before_save :update_published_at, if: :will_save_change_to_published?
  scope :published, -> { where(published: true) }
  scope :group_by_monthly, -> { group_by { |article| article.published_at&.strftime('%Y/%m') } }
  scope :group_by_yearly, -> { group_by { |article| article.published_at&.strftime('%Y') } }
  scope :get_by_month, -> (year, month){ group_by { |article| article.published_at&.strftime('%Y/%m') }["#{year}/#{month}"] }
  scope :get_by_year, -> (year){ group_by { |article| article.published_at&.strftime('%Y') }[year] }
  scope :tagged_by, -> (tag_name){ joins(:tags).where(tags: {name: tag_name}) }

  # scope :group_by_year_and_month, -> { group_by { |article| [article.published_at.strftime('%Y'), article.published_at.strftime('%Y-%m')] } }

  # XXX: hash→hash（valueのみ更新）したい場合
  # hash.map{} としてk,vへのアクセスをしやすくする
  # 最後にto_hでhashに変換し直す

  private

  def update_published_at
    return if skip_update_published_at
    return if published_was

    assign_attributes(published_at: Time.now)
  end
end
