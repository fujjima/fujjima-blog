class AddPublishedAtToArticles < ActiveRecord::Migration[6.0]
  def up
    add_column :articles, :published_at, :datetime
  end

  def down
    remove_column :articles, :published_at, :datetime
  end
end
