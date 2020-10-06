class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :login, null: false
      t.timestamps null: false
    end

    add_index :users, :login, unique: true
  end
end
