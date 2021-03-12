class Article < ApplicationRecord
  validates :published, inclusion: [true, false]
  validates :slug, presence: true
end
