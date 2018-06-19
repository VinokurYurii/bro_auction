class CreateLots < ActiveRecord::Migration[5.1]
  def change
    create_table :lots do |t|
      t.string :title, null: false
      t.string :image
      t.integer :user_id, null: false, references: [:user, :id], index: true
      t.text :description
      t.integer :status, default: 0, null: false
      t.decimal :start_price, scale: 2, precision: 12, null: false
      t.decimal :estimated_price, scale: 2, precision: 12, null: false

      t.timestamp :lot_start_time
      t.timestamp :lot_end_time
      t.timestamps
    end
    add_index :lots, :created_at
  end
end
