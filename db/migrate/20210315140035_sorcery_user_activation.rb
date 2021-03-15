class SorceryUserActivation < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :activation_state, :string, default: nil
    add_column :users, :activation_token, :string, default: nil
    add_column :users, :activation_token_expires_at, :datetime, default: nil

    add_index :users, :activation_token
  end

  def down
    remove_index :users, :activation_token

    remove_column :users, :activation_token_expires_at, :datetime, default: nil
    remove_column :users, :activation_token, :string, default: nil
    remove_column :users, :activation_state, :string, default: nil
  end
end
