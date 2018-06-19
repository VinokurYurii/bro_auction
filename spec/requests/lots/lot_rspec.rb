require "rails_helper"
# frozen_string_literal: true

RSpec.describe "Lot", type: :request do
  describe "GET lots" do
    before(:each) do
      @logged_user_headers = create(:user).create_new_auth_token
    end

    context "should return all lots" do
      it "response should be success" do
        get "/lots", headers: @logged_user_headers
        expect(response).to be_success
      end
    end
  end
end
