class RenameAdminsToUsers < ActiveRecord::Migration[6.0]
  def change
    rename_table :admins, :users
  end
end
