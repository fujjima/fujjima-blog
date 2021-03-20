class AddIndexToTagsName < ActiveRecord::Migration[6.0]
  def up
    add_index :tags, :name, unique: true
  end

  def down
    remove_index :tags, :name, unique: true
  end
end
