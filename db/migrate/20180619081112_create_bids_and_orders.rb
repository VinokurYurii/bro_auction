class CreateBidsAndOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :bids do |t|
      t.float :proposed_price, scale: 2, precision: 2, null: false
      t.integer :user_id, null: false, references: [:user, :id], index: true
      t.integer :lot_id, null: false, references: [:lot, :id], index: true

      t.timestamp :created_at
    end

    add_index :bids, [:user_id, :lot_id]

    create_table :orders do |t|
      t.string :arrival_location

      t.integer :arrival_type, null: false
      t.integer :status, default: 0, null: false

      t.integer :bid_id, null: false, references: [:bid, :id], index: true
      t.integer :lot_id, null: false, references: [:lot, :id], index: true

      t.timestamps
    end
  end
end
