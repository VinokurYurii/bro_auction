require "rails_helper"
# frozen_string_literal: true

RSpec.describe "UserLotIdentifier", type: :request do
  describe "bis must hide participants of auction from each other, but mark current user bids" do
    before(:each) do

      @user1 = create :user
      @user2 = create :user
      @user3 = create :user
      @lot = create :lot, user: @user1, start_price: 10.00, estimated_price: 100.00
      @bid1 = create :bid, user: @user2, lot: @lot, proposed_price: 20.00
      @bid2 = create :bid, user: @user3, lot: @lot, proposed_price: 30.00
      @bid3 = create :bid, user: @user2, lot: @lot, proposed_price: 40.00
      @logged_user_headers = @user2.create_new_auth_token
    end
    it "should return user identifier and match to his bid alias" do
      get "/lots/#{ @lot.id }", headers: @logged_user_headers
      lot = parse_json_string(response.body)[:resource]
      get "/bids", params: { lot_id: @lot.id }, headers: @logged_user_headers
      user_aliases = parse_json_string(response.body)[:resources].pluck :user_alias
      expect(user_aliases[0]).to eq lot[:user_identifier]
      expect(user_aliases[0]).to eq user_aliases[2]
      expect(user_aliases[0]).to_not eq user_aliases[1]
    end
  end
end
