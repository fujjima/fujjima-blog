class AddColumnToUsers < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :admin, :boolean, default: false, null: false
  end

  def down
    remove_column :users, :admin, :boolean, default: false, null: false
  end
end
