require "rails_helper"
# frozen_string_literal: true

RSpec.describe OrdersController, type: :controller do
  login(:user)
  before(:each) do
    @user1 = create :user
    @user2 = create :user
    @lot = create :lot, user_id: @user1.id, start_price: 10.00, estimated_price: 100.00
    @bid1 = create :bid, user_id: @user.id, proposed_price: 20.00, lot: @lot
    @bid2 = create :bid, user_id: @user2.id, proposed_price: 30.00, lot: @lot
    @bid3 = create :bid, user_id: @user.id, proposed_price: 40.00, lot: @lot
  end
  describe "POST /orders" do
    context "not closed lot" do
      it "should fail if lot not closed" do
        post :create, params: { lot_id: @lot.id, order: { arrival_location: "Some where", arrival_type: :pickup } }
        expect(response).to_not be_success
        expect(parse_json_string(response.body)[:error]).to eq("You are not authorized for this action")
      end
    end
    context "closed lot" do
      before :each do
        @lot.update!(status: :closed)
      end
      it "responce should be success" do
        post :create, params: { lot_id: @lot.id, order: { arrival_location: "Some where", arrival_type: :pickup } }
        expect(response).to be_success
      end
      context "not winner" do
        before :each do
          login_by_user @user2
        end
        it "should fail if not winner create order" do
          post :create, params: { lot_id: @lot.id, order: { arrival_location: "Some where", arrival_type: :pickup } }
          expect(response).to_not be_success
          expect(parse_json_string(response.body)[:error]).to eq("You are not authorized for this action")
        end
      end
    end
  end

  describe "PUT /orders/:id" do
    before :each do
      @lot.update!(status: :closed)
      @order = Order.create lot: @lot, bid: @bid3, arrival_location: "Some where", arrival_type: :pickup
    end
    context "should throw not order partial" do
      before :each do
        login_by_user @user2
      end
      it "should raise error for not order partial" do
        put :update, params: { id: @order.id, order: { arrival_location: "Some another place", arrival_type: :royal_mail } }
        expect(parse_json_string(response.body)[:error]).to eq("You are not authorized for this action")
      end
    end
    context "working with lot winner" do
      it "should update order arrival params if it in pending status" do
        put :update, params: { id: @order.id, order: { arrival_location: "Some another place", arrival_type: :royal_mail } }
        expect(response).to be_success
        expect(parse_json_string(response.body)[:resource])
            .to match(a_hash_including(arrival_location: "Some another place", arrival_type: "royal_mail"))
      end
      it "should update status from :sent to :delivered" do
        @order.update! status: :sent
        expect { put :update, params: { id: @order.id } }.to change { @order.reload.status }.from("sent").to("delivered")
      end
      it "should throw error if order if in :delivered status" do
        @order.update! status: :delivered
        put :update, params: { id: @order.id }
        expect(response.status).to eq 422
        expect(parse_json_string(response.body)[:error]).to eq "You are not authorized for this action"
      end
    end
    context "working with lot owner" do
      before :each do
        login_by_user @user1
      end
      it "should update status from :pending to :sent" do
        expect { put :update, params: { id: @order.id } }
            .to change { @order.reload.status }.from("pending").to("sent")
      end
      it "should throw error if order if in :sent status" do
        @order.update! status: :sent
        put :update, params: { id: @order.id }
        expect(response.status).to eq 422
        expect(parse_json_string(response.body)[:error]).to eq "You are not authorized for this action"
      end
      it "should throw error if order if in :delivered status" do
        @order.update! status: :delivered
        put :update, params: { id: @order.id }
        expect(response.status).to eq 422
        expect(parse_json_string(response.body)[:error]).to eq "You are not authorized for this action"
      end
    end
  end
end
