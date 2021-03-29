class AddUniqueIndexToArticleTag < ActiveRecord::Migration[6.0]
  def change
    add_index :article_tags, %w[article_id tag_id], unique: true
  end
end
