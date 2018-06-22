require "rails_helper"
# frozen_string_literal: true

RSpec.describe BidsController, type: :controller do
  login(:user)
  before(:each) do
    @lot = create :lot, user: @user, start_price: 10.00, estimated_price: 100.00
  end
  describe "GET /bids" do
    before(:each) do
      @user2 = create :user
      @user3 = create :user
      @bid1 = create :bid, user: @user2, lot: @lot, proposed_price: 20.00
      @bid2 = create :bid, user: @user3, lot: @lot, proposed_price: 30.00
      @bid3 = create :bid, user: @user2, lot: @lot, proposed_price: 40.00
    end
    it "response should be success and get 3 bids" do
      get :index, params: { lot_id: @lot.id }
      expect(response).to be_success
      expect(parse_json_string(response.body)[:resource].count).to eq(3)
    end
  end
end
