require "rails_helper"
# frozen_string_literal: true

RSpec.describe LotsController, type: :controller do
  login(:user)

  describe "GET /lots" do
    it "response should be success" do
      get :index
      expect(response).to be_success
    end

    context "should return all lots" do
      before(:each) do
        FactoryBot.create_list :lot, 10, user: @user
        FactoryBot.create_list :lot, 5, user: @user, status: :pending

        @user2 = User.create! attributes_for :user
        FactoryBot.create_list :lot, 8, user: @user2
        FactoryBot.create_list :lot, 5, user: @user2, status: :pending
      end

      it "should return 18 lots without params" do
        get :index
        expect(parse_json_string(response.body).count).to eq(18)
      end

      it "should return 15 lots by user for lot owner" do
        get :index,  params: { user_id: @user.id }
        expect(parse_json_string(response.body).count).to eq(15)
      end

      it "should return 8 lots by user, but not for lot owner" do
        get :index, params: { user_id: @user2.id }
        expect(parse_json_string(response.body).count).to eq(8)
      end

      it "should use serializer" do
        get :index,  params: { user_id: @user.id }
        expect(parse_json_string(response.body)[0])
            .to eq(get_serialize_object(Lot.where(user_id: @user.id).first, LotSerializer))
      end
    end
  end

  describe "POST /lots" do
    subject { post :create, params: { lot: attributes_for(:lot, title: @title) } }
    context "valid title" do
      before(:each) do
        @title = "Test title"
      end

      it "response for create should be success" do
        subject
        expect(response).to be_success
      end

    end

    context "not valid title" do
      before(:each) do
        @tile = nil
      end
      it "not valid " do
        subject
        expect(parse_json_string(response.body)[:errors][:title]).to eq(["can't be blank"])
      end
    end
  end
end
