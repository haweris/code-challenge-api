class CreateArticles < ActiveRecord::Migration[7.1]
  def change
    create_table :articles do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.string :author_name, null: false
      t.datetime :published_at
      t.references :author, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
