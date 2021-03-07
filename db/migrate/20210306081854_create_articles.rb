class CreateArticles < ActiveRecord::Migration[6.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :text
      t.boolean :published, default: false, null: false
      t.string :slug, null: false, index: { unique: true }
      t.text :image

      t.timestamps
    end
  end
end
