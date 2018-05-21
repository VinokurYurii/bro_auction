class CreateLots < ActiveRecord::Migration[5.1]
  def change
    create_table :lots do |t|
      t.string :title, :null => false
      t.string :image
      t.text :description
      t.integer :status, :default => :pending, :null => false
      t.decimal :current_price, :scale => 2, :precision => 2, :null => false
      t.decimal :estimated_price, :scale => 2, :precision => 2, :null => false

      t.timestamp :lot_start_time
      t.timestamp :lot_end_time
      t.timestamps
    end
    add_index :lots, :created_at
  end
end