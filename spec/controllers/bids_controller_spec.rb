require "rails_helper"
# frozen_string_literal: true

RSpec.describe BidsController, type: :controller do
  login(:user)
  before(:each) do
    @lot = create :lot, user: @user, start_price: 10.00, estimated_price: 100.00
    @user2 = create :user
  end
  describe "GET /bids" do
    before(:each) do
      @user3 = create :user
      @bid1 = create :bid, user: @user2, lot: @lot, proposed_price: 20.00
      @bid2 = create :bid, user: @user3, lot: @lot, proposed_price: 30.00
      @bid3 = create :bid, user: @user2, lot: @lot, proposed_price: 40.00
    end
    subject { get :index, params: { lot_id: @lot.id } }
    it "response should be success and get 3 bids" do
      subject
      expect(response).to be_success
      expect(parse_json_string(response.body)[:resource].count).to eq(3)
    end
    context "check winner logic" do
      before :each do
        login_by_user @user2
      end
      it "should change lot status after creating bid with proposed price equal to estimated price" do
        post :create, params: { bid: { lot_id: @lot.id, proposed_price: 100.00 } }
        expect(@lot.reload.status).to eq "closed"
      end
      it "should change lot status after creating bid greater than estimated price" do
        post :create, params: { bid: { lot_id: @lot.id, proposed_price: 110.00 } }
        expect(@lot.reload.status).to eq "closed"
      end
      it "overhead bid should be winner and other was losers" do
        @bid = Bid.create proposed_price: 110.00, user: @user2, lot: @lot
        subject
        bids = parse_json_string(response.body)[:resource]
        winner = bids.select { |bid| bid[:id] == @bid.id } .first
        others = bids.select { |bid| bid[:id] != @bid.id }
        expect(winner[:is_winner]).to eq true
        expect(others.map { |other| other[:is_winner] } .select { |status| !status } . count)
            .to eq others.count
      end
      it "should be only one winner"
    end
    context "bis must hide participants of auction from each other, but mark current user bids" do
      context "change user for user2" do
        before :each do
          login_by_user @user2
        end
        it "should add 'Your' for current user alias" do
          subject
          expect(parse_json_string(response.body)[:resource].pluck :user_alias).to eq ["Your", "Customer 1", "Your"]
        end
      end
      it "should add 'Customer #' as current users alias" do
        subject
        expect(parse_json_string(response.body)[:resource].pluck :user_alias).to eq ["Customer 1", "Customer 2", "Customer 1"]
      end
    end
  end

  describe "POST /bids" do
    it "shouldn't create bid if user lot creator" do
      post :create, params: { bid: { lot_id: @lot.id, proposed_price: 20.00 } }
      expect(response.status).to eq 422
      expect(parse_json_string(response.body)[:errors][:user]).to eq ["Lot creator couldn't create bid for his lot(s)"]
    end
    context "change user for not creator" do
      before :each do
        login_by_user @user2
      end
      it "should create bid if user != lot creator and bid greater than current price" do
        post :create, params: { bid: { lot_id: @lot.id, proposed_price: 20.00 } }
        expect(response).to be_success
      end
      it "shouldn't create bid if proposed price less than current price" do
        post :create, params: { bid: { lot_id: @lot.id, proposed_price: 9.99 } }
        expect(response).to_not be_success
        expect(parse_json_string(response.body)[:errors][:proposed_price])
            .to eq ["Proposed_price must be greater that lot.current_price"]
      end
    end
  end
end
