class Article < ApplicationRecord
  has_many :article_tags, dependent: :destroy
  has_many :tags, through: :article_tags

  validates :published, inclusion: [true, false]
  validates :slug, presence: true

  before_save :update_published_at, if: :will_save_change_to_published?
  scope :published, -> { where(published: true) }

  private

  def update_published_at
    return if published_was

    assign_attributes(published_at: Time.now)
  end
end
