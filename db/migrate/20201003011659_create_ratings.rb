class CreateRatings < ActiveRecord::Migration[5.1]
  def change
    create_table :ratings do |t|
      t.integer :value, null: false
      t.references :post, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
