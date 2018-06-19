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
end
