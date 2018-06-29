require "rails_helper"
# frozen_string_literal: true

RSpec.describe BidsChannel, type: :channel do

  it "subscribes to a stream" do
    subscribe(lot_id: 2)
    expect(subscription).to be_confirmed
    expect(streams).to include("bids_for_lot_2")
  end

  it "Reject if no params provided" do
    subscribe
    expect(subscription).to be_rejected
  end
end
