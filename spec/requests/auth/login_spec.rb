require 'rails_helper'

RSpec.describe "Login", type: :request do
  describe "POST login" do

    let(:data) do
      {
          email: Faker::Internet.free_email,
          password: "password"
      }

    end

    before(:each) do
      @user = create :user, data
    end

    context "when user was logged successful" do
      subject {post "/users/sign_in", params: data}

      it "response should be success" do
        subject
        expect(response).to be_success
      end
    end

    context "when user try login with wrong parameters" do
      it "response should be 401 status with wrong password" do
        post "/users/sign_in", params: {:email => data[:email], :password => 'ppassword'}
        expect(response.status).to eq 401
      end

      it "response should be 401 status with wrong email" do
        post "/users/sign_in", params: {:email => 'some_prefix_' + data[:email], :password => data[:password]}
        expect(response.status).to  eq 401
      end
    end
  end
end