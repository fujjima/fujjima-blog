class RemoveIndexFromArticle < ActiveRecord::Migration[6.0]
  def change
    remove_index :articles, :slug
  end
end
