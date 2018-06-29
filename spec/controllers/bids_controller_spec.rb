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
      expect(parse_json_string(response.body)[:resources].count).to eq(3)
    end
    context "check winner logic" do
      before :each do
        login_by_user @user2
      end
      it "should change lot status after creating bid with proposed price equal to estimated price" do
        expect { post :create, params: { bid: { lot_id: @lot.id, proposed_price: 100.00 } } }
            .to change { @lot.reload.status } .from("in_progress").to("closed")
      end
      it "should change lot status after creating bid greater than estimated price" do
        expect { post :create, params: { bid: { lot_id: @lot.id, proposed_price: 110.00 } } }
            .to change { @lot.reload.status } .from("in_progress").to("closed")
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
      it "should broadcast bid creation to lot chanel" do
        expect { post :create, params: { bid: { lot_id: @lot.id, proposed_price: 28.11 } } }
            .to have_broadcasted_to("bids_for_lot_#{@lot.id}")
                    .with(a_hash_including(
                            proposed_price: 28.11,
                            user_alias: ApplicationRecord.generate_hash([@lot.id, @user2.id])
                          ))
      end
      it "shouldn't create bid if proposed price less than current price" do
        post :create, params: { bid: { lot_id: @lot.id, proposed_price: 9.99 } }
        expect(response).to_not be_success
        expect(parse_json_string(response.body)[:errors][:proposed_price])
            .to eq ["Proposed_price must be greater that lot.current_price"]
      end
    end
  end

  describe "DELETE /bids/:id" do
    before(:each) do
      login_by_user @user2
      @user3 = create :user
      @bid1 = create :bid, user: @user2, lot: @lot, proposed_price: 20.00
      @bid2 = create :bid, user: @user3, lot: @lot, proposed_price: 30.00
      @bid3 = create :bid, user: @user2, lot: @lot, proposed_price: 40.00
    end
    it "should delete bid by bid creator and lot :in_progress status" do
      delete :destroy, params: { id: @bid3.id }
      expect(response).to be_success
      expect(@lot.reload.bids.count).to eq 2
    end
    it "shouldn't delete bid by not bid creator" do
      delete :destroy, params: { id: @bid2.id }
      expect(response).to_not be_success
      expect(parse_json_string(response.body)[:error]).to eq("You are not authorized for this action")
    end
    it "shouldn't delete bid by bid creator and lot :closed status" do
      @lot.update! status: :closed
      delete :destroy, params: { id: @bid3.id }
      expect(response).to_not be_success
      expect(parse_json_string(response.body)[:error]).to eq("You are not authorized for this action")
    end
  end
end
