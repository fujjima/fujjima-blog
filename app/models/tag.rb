class Tag < ApplicationRecord
  has_many :article_tags, dependent: :destroy
  has_many :articles, through: :article_tags

  validates :name, presence: true

  # 更新処理をmodelに寄せる
  # https://qiita.com/h1kita/items/7fdb5d95c883e38c63fc#%E6%95%A3%E3%82%89%E3%81%B0%E3%81%A3%E3%81%9F%E6%9B%B4%E6%96%B0%E5%87%A6%E7%90%86

  class << self

    # tagsにはタグ名の配列を渡す
    # ex) [tag1, tag2]
    def insert_new_tag(tags)
      insert_all(tags_to_hash_for_insert(tags))
    end

    def new_tags(tag_names_ary)
      Tag.where(name: tag_names_ary)
    end

    private

    def tags_to_hash_for_insert(ary)
      ary.map do |val|
        {"name": val, created_at: Time.current, updated_at: Time.current}
      end
    end
  end
end
