class AddJwtStrategyForUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :allowlisted_jwts do |t|
      t.string :jti, null: false
      t.string :aud
      t.datetime :exp, null: false
      t.references :user, foreign_key: { to_table: :users, on_delete: :cascade }, null: false
    end

    add_index :allowlisted_jwts, :jti, unique: true
  end
end
