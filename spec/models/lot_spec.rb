# frozen_string_literal: true

# == Schema Information
#
# Table name: lots
#
#  id              :bigint(8)        not null, primary key
#  description     :text
#  estimated_price :decimal(12, 2)   not null
#  image           :string
#  lot_end_time    :datetime
#  lot_start_time  :datetime
#  start_price     :decimal(12, 2)   not null
#  status          :integer          default("pending"), not null
#  title           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer          not null
#
# Indexes
#
#  index_lots_on_created_at  (created_at)
#  index_lots_on_user_id     (user_id)
#

require "rails_helper"

RSpec.describe Lot, type: :model do

  before(:each) do
    @user = create(:user)
    @time = DateTime.now
  end

  it "is lot valid with start_date greater or equal to current time" do
    lot = create(:lot, user_id: @user.id)
    expect(lot).to be_valid
  end
  it "is lot valid with stop_date greater than start_date" do
    lot = create(:lot, user_id: @user.id)
    expect(lot).to be_valid
  end
  it "is lot not valid with start_date greater then stop_date" do
    lot = Lot.new(attributes_for(:lot,
                                 user_id: @user.id,
                                 lot_start_time: DateTime.now - 1.hour,
                                 lot_end_time: DateTime.now - 3.month))
    expect(lot).to_not be_valid
  end
  it "is lot not valid with start_date less then current time" do
    lot = Lot.new(attributes_for(:lot, lot_start_time: DateTime.now - 1.hour, user_id: @user.id))
    expect(lot).to_not be_valid
  end
  it "should set status to :in_progress if lot_start_time less or equal then now and status :pending" do
    @lot = create :lot, user_id: @user.id, lot_start_time: DateTime.now, status: :pending
    @lot.check_time_and_status
    expect(@lot.reload.status).to eq "in_progress"
  end
  it "should set status to :closed if lot_end_time less or equal then now and status not :closed" do
    @lot = create :lot, user_id: @user.id,
                  lot_start_time: DateTime.now,
                  lot_end_time: DateTime.now
    @lot.check_time_and_status
    expect(@lot.reload.status).to eq "closed"
  end

  context "check current price changes" do
    before(:each) do
      @user = create :user
      @user2 = create :user
      @user3 = create :user
      @lot = create :lot, user: @user, start_price: 10.00, estimated_price: 100.00
      @bid1 = create :bid, user: @user2, lot: @lot, proposed_price: 20.00
      @bid2 = create :bid, user: @user3, lot: @lot, proposed_price: 30.00
      @bid3 = create :bid, user: @user2, lot: @lot, proposed_price: 40.00
    end
    it "lot current_price must should change after deleting max bid" do
      expect { @bid3.destroy! }.to change { @lot.reload.current_price }.from(40.00).to(30.00)
    end
    it "lot current_price must shouldn't change after deleting not max bid" do
      expect { @bid2.destroy! }.to_not change { @lot.reload.current_price }
    end
  end
end
