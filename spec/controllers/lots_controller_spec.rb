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
        create_list :lot, 10, user: @user
        create_list :lot, 5, user: @user, status: :pending

        @user2 = create :user
        create_list :lot, 8, user: @user2
        create_list :lot, 5, user: @user2, status: :pending
      end

      it "should return 10 lots without params" do
        get :index
        expect(parse_json_string(response.body)[:resources].count).to eq(10)
      end

      it "should return 8 lots with page 2" do
        get :index, params: { page: 2 }
        expect(parse_json_string(response.body)[:resources].count).to eq(8)
      end

      it "check :is_my lot property: should return 8 false and 10 true :is_my" do
        get :index, params: { per_page: 20 }
        is_my_array = parse_json_string(response.body)[:resources].pluck(:is_my)
        expect(is_my_array.select { |is_my| !is_my } .count).to eq 8
        expect(is_my_array.select { |is_my| is_my } .count).to eq 10
      end

      it "should return 10 lots by user for lot owner without bids" do
        get :index, params: { user_id: @user.id }
        expect(parse_json_string(response.body)[:resources].count).to eq(10)
      end

      it "should return 8 lots by user, but not for lot owner without bids" do
        get :index, params: { user_id: @user2.id }
        expect(parse_json_string(response.body)[:resources].count).to eq(8)
      end

      context "finding lots with lot where user take part as customer" do
        before :each do
          @bid = create :bid, lot: @lot = @user2.lots.first, user: @user, proposed_price: @lot.current_price + 10.00
        end

        it "should return 6 lots with page 2" do
          get :index, params: { user_id: @user.id, page: 2 }
          expect(parse_json_string(response.body)[:resources].count).to eq(6)
        end
      end

      it "should use serializer" do
        get :index,  params: { user_id: @user.id }
        serialized_lot = get_serialize_object(Lot.find_user_lots(@user.id, @user.id).order(id: :desc).first, LotSerializer)
        serialized_lot[:is_my] = true
        expect(parse_json_string(response.body)[:resources][0])
            .to eq(serialized_lot)
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

  describe "PUT /lots/:id" do
    before(:each) do
      @lot = create :lot, user: @user, status: :pending
    end
    subject { put :update, params: { id: @lot.id, lot: { title: "Not GoT theme" } } }
    context "update with valid user and pending status" do
      it "update with creator user" do
        expect { subject } .to change { @lot.reload.title } .to("Not GoT theme")
      end
    end

    context "update with valid user and not :pending status" do

      context ":in_progress" do
        before(:each) do
          @lot = create :lot, user: @user, status: :in_progress
        end
        it "update with creator user and :in_progress status" do
          expect { subject } .to_not change { @lot.reload.title }
        end
      end

      context ":closed" do
        before(:each) do
          @lot = create :lot, user: @user, status: :closed
        end
        it "update with creator user" do
          expect { subject } .to_not change { @lot.reload.title }
        end
      end
    end

    context "update with not valid user" do
      before(:each) do
        @user2 = create :user
        login_by_user @user2
      end
      it "update with not creator user reject" do
        expect { subject } .to_not change { @lot.reload.title }
      end
      it "update with not creator user reject message" do
        subject
        expect(parse_json_string(response.body)[:error]).to eq("You are not authorized for this action")
      end
    end
  end

  describe "DELETE /lots/:id" do
    before(:each) do
      @lot = create :lot, user: @user, status: :pending
    end
    subject { delete :destroy, params: { id: @lot.id } }
    context "delete with valid user and pending status" do
      it "delete with creator user" do
        subject
        expect(response.status).to eq 200
      end
    end
    context "delete with valid user and not :pending status" do

      context ":in_progress" do
        before(:each) do
          @lot = create :lot, user: @user, status: :in_progress
        end
        it "delete with creator user and :in_progress status" do
          subject
          expect(Lot.where(id: @lot.id).present?).to be
        end
      end

      context ":closed" do
        before(:each) do
          @lot = create :lot, user: @user, status: :closed
        end
        it "delete with creator user" do
          subject
          expect(@lot.reload.present?).to be
          expect(response.status).to eq 422
        end
      end
    end

    context "delete with not valid user" do
      before(:each) do
        @user2 = create :user
        login_by_user @user2
      end

      it "delete with not creator user reject" do
        subject
        expect(Lot.where(id: @lot.id).present?).to be
        expect(parse_json_string(response.body)[:error]).to eq("You are not authorized for this action")
      end
    end
  end

  describe "GET /lots/:id" do
    subject { get :show, params: { id: @lot.id } }
    context "work with creator lot user" do
      context ":pending status" do
        before(:each) do
          @lot = create :lot, user: @user, status: :pending
        end
        it "should show lot with :pending status" do
          subject
          expect(parse_json_string(response.body)[:resource][:id]).to eq @lot.id
          current_lot = Lot.find(@lot.id)
          current_lot.user_identifier = ApplicationRecord.generate_hash([@lot.id, @user.id])
          expect(parse_json_string(response.body)[:resource])
              .to eq(get_serialize_object(current_lot, LotSerializer))
        end
        it "should return 404 for not existed lot" do
          get :show, params: { id: 10000 }
          expect(response.status).to eq 404
          expect(parse_json_string(response.body)[:error]).to eq("Post not fount")
        end
      end

      context ":in_progress status" do
        before(:each) do
          @lot = create :lot, user: @user, status: :in_progress
        end
        it "should show lot with :in_progress status" do
          subject
          expect(parse_json_string(response.body)[:resource][:id]).to eq @lot.id
        end
      end

      context ":closed status" do
        before(:each) do
          @lot = create :lot, user: @user, status: :closed
        end
        it "should show lot with :closed status" do
          subject
          expect(parse_json_string(response.body)[:resource][:id]).to eq @lot.id
        end
      end
    end

    context "work with not creator lot user" do
      before(:each) do
        @user2 = create :user
        login_by_user @user2
      end

      context ":pending status" do
        before(:each) do
          @lot = create :lot, user: @user, status: :pending
        end
        it "shouldn't show lot with :pending status" do
          subject
          expect(parse_json_string(response.body)[:error]).to eq("You are not authorized for this action")
        end
      end

      context ":in_progress status" do
        before(:each) do
          @lot = create :lot, user: @user, status: :in_progress
        end
        it "should show lot with :in_progress status" do
          subject
          expect(parse_json_string(response.body)[:resource][:id]).to eq @lot.id
        end
      end

      context ":closed status" do
        before(:each) do
          @lot = create :lot, user: @user, status: :closed
        end
        it "should show lot with :closed status" do
          subject
          expect(parse_json_string(response.body)[:resource][:id]).to eq @lot.id
        end
      end
    end

    context "Check lot winner" do
      before :each do
        @lot = create :lot, user: @user, start_price: 10.00, estimated_price: 100.00
        @user2 = create :user
        @user3 = create :user
        create :bid, user: @user3, lot: @lot, proposed_price: 20.00
        create :bid, user: @user2, lot: @lot, proposed_price: 30.00
        create :bid, user: @user3, lot: @lot, proposed_price: 40.00
        create :bid, user: @user2, lot: @lot, proposed_price: 110.00

        login_by_user @user2
      end
      it "User with closed bid must be winner" do
        subject
        expect(parse_json_string(response.body)[:resource][:user_won]).to eq true
      end
      context "Other users wouldn't be winner" do
        before :each do
          login_by_user @user3
        end
        it "User with lower bid wouldn't be winner" do
          subject
          expect(parse_json_string(response.body)[:resource][:user_won]).to eq false
        end
      end
    end
  end
end
