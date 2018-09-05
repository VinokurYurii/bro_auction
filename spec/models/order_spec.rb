# frozen_string_literal: true

# == Schema Information
#
# Table name: orders
#
#  id               :bigint(8)        not null, primary key
#  arrival_location :string
#  arrival_type     :integer          not null
#  status           :integer          default(0), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  bid_id           :integer          not null
#  lot_id           :integer          not null
#
# Indexes
#
#  index_orders_on_bid_id  (bid_id)
#  index_orders_on_lot_id  (lot_id)
#

require "rails_helper"

RSpec.describe Order, type: :model do
  before(:each) do
    @user1 = create :user
    @user2 = create :user
    @user3 = create :user
    @lot = create :lot, user_id: @user1.id, start_price: 10.00, estimated_price: 100.00
    @bid1 = create :bid, user_id: @user2.id, proposed_price: 20.00, lot: @lot
    @bid2 = create :bid, user_id: @user3.id, proposed_price: 30.00, lot: @lot
    @bid3 = create :bid, user_id: @user2.id, proposed_price: 40.00, lot: @lot
  end

  it "is order not valid if created on unclosed lot" do
    @order = Order.create(lot_id: @lot.id, bid_id: @bid3.id, arrival_location: "Some where", arrival_type: :pickup)
    expect(@order).to_not be_valid
    expect(@order.errors.messages[:lot]).to eq ["Lot must be closed for creating order"]
  end

  context "closed lot" do
    before :each do
      @lot.update! status: :closed
    end
    it "is order not valid if created with not winner bid" do
      @order = Order.create(lot_id: @lot.id, bid_id: @bid2.id, arrival_location: "Some where", arrival_type: :pickup)
      expect(@order).to_not be_valid
      expect(@order.errors.messages[:bid]).to eq ["Only winner bid must be in order"]
    end

    it "is order not valid if created with not winner bid even if user winner" do
      @order = Order.create(lot_id: @lot.id, bid_id: @bid1.id, arrival_location: "Some where", arrival_type: :pickup)
      expect(@order).to_not be_valid
      expect(@order.errors.messages[:bid]).to eq ["Only winner bid must be in order"]
    end

    it "is order valid if created with winner" do
      @order = Order.create(lot_id: @lot.id, bid_id: @bid3.id, arrival_location: "Some where", arrival_type: :pickup)
      expect(@order).to be_valid
    end
  end
end
