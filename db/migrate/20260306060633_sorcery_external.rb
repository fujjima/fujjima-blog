class SorceryExternal < ActiveRecord::Migration[7.1]
  def change
    create_table :authentications do |t|
      t.references :user,     null: false, foreign_key: true
      t.string     :provider, null: false
      t.string     :uid,      null: false

      t.timestamps null: false
    end

    add_index :authentications, %i[provider uid]
  end
end
