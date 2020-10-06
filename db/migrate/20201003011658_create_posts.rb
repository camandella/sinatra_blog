class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.string :author_ip, null: false
      t.references :user, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
