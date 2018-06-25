# frozen_string_literal: true

# == Schema Information
#
# Table name: bids
#
#  id             :bigint(8)        not null, primary key
#  proposed_price :float            not null
#  created_at     :datetime
#  lot_id         :integer          not null
#  user_id        :integer          not null
#
# Indexes
#
#  index_bids_on_lot_id              (lot_id)
#  index_bids_on_user_id             (user_id)
#  index_bids_on_user_id_and_lot_id  (user_id,lot_id)
#


require "rails_helper"

RSpec.describe Bid, type: :model do
  before(:each) do
    @user  = create(:user)
    @user2 = create(:user)
    @lot   = create(:lot, user_id: @user.id, start_price: 10.00)
  end
  it "should be valid if proposed price greater than lot current price and user != lot creator" do
    bid = create(:bid, user_id: @user2.id, lot: @lot, proposed_price: 20.00)
    expect(bid).to be_valid
  end
  it "should be not valid if proposed price less than lot current price" do
    bid = Bid.new(attributes_for(:bid,
                                 proposed_price: 9.99,
                                 user: @user2,
                                 lot: @lot))
    expect(bid).to_not be_valid
  end
  it "should be not valid if creator try create bid for his lot" do
    bid = Bid.new(attributes_for(:bid,
                                 proposed_price: 20.00,
                                 user: @user,
                                 lot: @lot))
    expect(bid).to_not be_valid
  end
  context "check lot status" do
    before :each do
      @lot2 = create(:lot, user_id: @user.id, start_price: 10.00, status: :pending)
      @lot3 = create(:lot, user_id: @user.id, start_price: 10.00, status: :closed)
    end
    it "should be not valid if lot status :pending" do
      bid = Bid.new(attributes_for(:bid,
                                   proposed_price: 20.00,
                                   user: @user2,
                                   lot: @lot2))
      expect(bid).to_not be_valid
    end
    it "should be not valid if lot status :closed" do
      bid = Bid.new(attributes_for(:bid,
                                   proposed_price: 20.00,
                                   user: @user2,
                                   lot: @lot3))
      expect(bid).to_not be_valid
    end
  end
end
