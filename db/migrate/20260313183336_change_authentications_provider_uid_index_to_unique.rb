class ChangeAuthenticationsProviderUidIndexToUnique < ActiveRecord::Migration[7.1]
  def change
    remove_index :authentications, [:provider, :uid], name: "index_authentications_on_provider_and_uid"
    add_index :authentications, [:provider, :uid], unique: true
  end
end
